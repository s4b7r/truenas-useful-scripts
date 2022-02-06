#!/usr/bin/env bash
#
# Send drive identification info via Email.

readonly SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# shellcheck source=user.example.conf
source "${SCRIPT_PATH}/user.conf"
# shellcheck source=global.conf
source "${SCRIPT_PATH}/global.conf"
# shellcheck source=format_email.sh
source "${SCRIPT_PATH}/format_email.sh"

readonly EMAIL_SUBJECT="TrueNAS $(hostname): Drive identifications"
readonly EMAIL_BODY="/tmp/drive_identifications.html"

(
  # Only specify monospace font to let Email client decide of the rest.
  echo "<pre style=\"font-family:monospace\">"
  echo "<b>Drive identification info</b>"
  echo ""
) > "${EMAIL_BODY}"

(
echo "+========+============================================+=================+"
echo "| Device | GPTID                                      | Serial          |"
echo "+========+============================================+=================+"

for drive_label in ${SATA_DRIVES}; do
  gptid="$(glabel status -s "${drive_label}p2" | awk '{print $1}')"
  serial_number="$(smartctl -i /dev/"${drive_label}" | grep "Serial Number" | awk '{print $3}')"
  printf "| %-6s | %-42s | %-15s |\n" "${drive_label}" "${gptid}" "${serial_number}"
  echo "+--------+--------------------------------------------+-----------------+"
done

echo ""
echo "-- End of drive identification info --"
echo "</pre>"
) >> "${EMAIL_BODY}"

format_email "${EMAIL_SUBJECT}" "${EMAIL_ADDRESS}" "${EMAIL_BODY}" "${TAR_FILE}" | sendmail -i -t
rm "${EMAIL_BODY}"
