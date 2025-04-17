{ config, lib, pkgs, options, ... }:

let
  cfg = config.mobile.quirks.qualcomm;
  inherit (lib)
    any
    id
    mkIf
    mkOption
    optional
    types
  ;
  anyCompatible = any id [
    cfg.sdm845-modem.enable
    cfg.sc7180-modem.enable
  ];

in {
  options.mobile = {
    quirks.qualcomm.sc7180-modem.enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable this on a mainline-based SC7180 device for modem/Wi-Fi support
      '';
    };
    quirks.qualcomm.sdm845-modem.enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable this on a mainline-based SDM845 device for modem support
      '';
    };
  };
  config = mkIf anyCompatible {
    systemd.services = {
      rmtfs = {
        wantedBy = ["multi-user.target"];
        serviceConfig = {
          # https://github.com/andersson/rmtfs/blob/7a5ae7e0a57be3e09e0256b51b9075ee6b860322/rmtfs.c#L507-L541
          ExecStart = "${pkgs.rmtfs}/bin/rmtfs -r -P -s";
          Restart = "always";
          RestartSec = "1";
        };
      };
      tqftpserv = {
        wantedBy = ["multi-user.target"];
        before = ["rmtfs.service"];
        requiredBy = ["rmtfs.service"];
        serviceConfig = {
          ExecStart = "${pkgs.tqftpserv}/bin/tqftpserv";
          Restart = "always";
          RestartSec = "1";
        };
      };
      msm-modem-uim-selection = {
        before = ["ModemManager.service"];
        after = ["rmtfs.service"];
        requires = ["rmtfs.service"];
        wantedBy = ["multi-user.target"];
        requiredBy = ["ModemManager.service"];
        path = with pkgs; [libqmi gawk gnugrep];
        # https://gitlab.postmarketos.org/postmarketOS/pmaports/-/blob/master/modem/msm-modem/msm-modem-uim-selection
        script = ''
          SIM_WAIT_TIME="1"
          QMICLI_MODEM=

          if command -v systemd-notify > /dev/null; then
          	trap '[ $? -eq 0 ] && systemd-notify --ready' EXIT
          fi

          case "$(cat /sys/devices/soc0/machine)" in
          APQ*)
          	echo 'Skipping SIM configuration on APQ SoC.'
          	exit 0
          esac

          # libqmi must be present to use this script.
          if ! [ -x "$(command -v qmicli)" ]
          then
          	echo 'qmicli is not installed.'
          	exit 1
          fi

          # Prepare a qmicli command with desired modem path.
          # The modem may appear after some delay, wait for it.
          count=0
          while [ -z "$QMICLI_MODEM" ] && [ "$count" -lt "45" ]
          do
          	# Check if legacy rpmsg exported device exists.
          	if [ -e "/dev/modem" ]
          	then
          		QMICLI_MODEM="qmicli --silent -d /dev/modem"
          		echo "Using /dev/modem"
          	# Check if the qmi device from wwan driver exists.
          	elif [ -e "/dev/wwan0qmi0" ]
          	then
          		# Using --device-open-qmi flag as we may have libqmi
          		# version that can't automatically detect the type yet.
          		QMICLI_MODEM="qmicli --silent -d /dev/wwan0qmi0 --device-open-qmi"
          		echo "Using /dev/wwan0qmi0"
          	# Check if QRTR is available for new devices.
          	elif qmicli --silent -pd qrtr://0 --uim-noop > /dev/null
          	then
          		QMICLI_MODEM="qmicli --silent -pd qrtr://0"
          		echo "Using qrtr://0"
          	fi
          	sleep 1
          	count=$((count+1))
          done
          echo "Waited $count seconds for modem device to appear"

          if [ -z "$QMICLI_MODEM" ]
          then
          	echo 'No modem available.'
          	exit 2
          fi

          QMI_CARDS=$($QMICLI_MODEM --uim-get-card-status)

          # Stop if all slots are empty but wait a bit for the sim to appear.
          count=0
          while ! printf "%s" "$QMI_CARDS" | grep -Fq "Card state: 'present'"
          do
          	if [ "$count" -ge "$SIM_WAIT_TIME" ]
          	then
          		echo "No sim detected after $SIM_WAIT_TIME seconds."
              # Changed from 4 to 0 b/c failing the unit for not having a sim card
              # is annoying.
          		exit 0
          	fi

          	sleep 1
          	count=$((count+1))
          	QMI_CARDS=$($QMICLI_MODEM --uim-get-card-status)
          done
          echo "Waited $count seconds for modem to come up"

          # Clear the selected application in case the modem is in a bugged state
          if ! printf "%s" "$QMI_CARDS" | grep -Fq "Primary GW:   session doesn't exist"
          then
          	echo 'Application was already selected.'
          	$QMICLI_MODEM --uim-change-provisioning-session='activate=no,session-type=primary-gw-provisioning' > /dev/null
          fi

          # Extract first available slot number and AID for usim application
          # on it. This should select proper slot out of two if only one UIM is
          # present or select the first one if both slots have UIM's in them.
          FIRST_PRESENT_SLOT=$(printf "%s" "$QMI_CARDS" | grep "Card state: 'present'" -m1 -B1 | head -n1 | cut -c7-7)
          FIRST_PRESENT_AID=$(printf "%s" "$QMI_CARDS" | grep "usim (2)" -m1 -A3 | tail -n1 | awk '{print $1}')

          echo "Selecting $FIRST_PRESENT_AID on slot $FIRST_PRESENT_SLOT"

          # Finally send the new configuration to the modem.
          $QMICLI_MODEM --uim-change-provisioning-session="slot=$FIRST_PRESENT_SLOT,activate=yes,session-type=primary-gw-provisioning,aid=$FIRST_PRESENT_AID" > /dev/null
        '';
        serviceConfig = {
          Type = "notify";
          RemainAfterExit = true;
        };
      };
    };
  };
}
