#!/bin/sh

GITHUB_SETUP_ROOT="$(git rev-parse --show-toplevel)"
GITHUB_SETUP_SSH_FOLDER="${GITHUB_SETUP_ROOT}/.ssh"
GITHUB_SETUP_SSH_KEY='id_ed25519'
read -p "Your GitHub email: " GITHUB_SETUP_EMAIL > /dev/tty
read -p "Your GitHub pseudo: " GITHUB_SETUP_USER > /dev/tty

GITHUB_SETUP_SSH_FILES="${GITHUB_SETUP_SSH_FOLDER}/${GITHUB_SETUP_SSH_KEY}_auth ${GITHUB_SETUP_SSH_FOLDER}/${GITHUB_SETUP_SSH_KEY}_auth.pub ${GITHUB_SETUP_SSH_FOLDER}/${GITHUB_SETUP_SSH_KEY}_sign ${GITHUB_SETUP_SSH_FOLDER}/${GITHUB_SETUP_SSH_KEY}_sign.pub"
for file in "${GITHUB_SETUP_SSH_FILES}"; do
    if [ ! -f "${file}" ]; then
        rm -rf "${GITHUB_SETUP_SSH_FOLDER}"
        mkdir -p "${GITHUB_SETUP_SSH_FOLDER}"
        ssh-keygen -t ed25519 -a 100 -C "${GITHUB_SETUP_EMAIL}" -f "${GITHUB_SETUP_SSH_FOLDER}/${GITHUB_SETUP_SSH_KEY}_auth" -N "" > /dev/null
        ssh-keygen -t ed25519 -a 100 -C "${GITHUB_SETUP_EMAIL}" -f "${GITHUB_SETUP_SSH_FOLDER}/${GITHUB_SETUP_SSH_KEY}_sign" -N "" > /dev/null
        break
    fi
done
chmod -R 0600 "${GITHUB_SETUP_SSH_FOLDER}"
chmod +r "${GITHUB_SETUP_SSH_FOLDER}"/*.pub
chmod +x "${GITHUB_SETUP_SSH_FOLDER}"

git config user.signingkey "${GITHUB_SETUP_SSH_FOLDER}/${GITHUB_SETUP_SSH_KEY}_sign"
git config core.sshCommand "ssh -i ${GITHUB_SETUP_SSH_FOLDER}/${GITHUB_SETUP_SSH_KEY}_auth -F /dev/null"

git config user.name "${GITHUB_SETUP_USER}"
git config user.email "${GITHUB_SETUP_EMAIL}"
git config commit.gpgsign true
git config gpg.format ssh
git config pull.rebase false
git config push.default simple
git config core.editor "code --wait"
git config merge.tool vimdiff
git config mergetool.prompt false
git config core.autocrlf input
git config core.safecrlf true
git config color.ui auto
git config color.branch auto
git config color.diff auto
git config color.status auto
git config commit.cleanup strip
git config log.abbrevCommit true
git config log.showSignature true

GITHUB_SETUP_ASSETS_FOLDER="${GITHUB_SETUP_ROOT}/assets"
mkdir -p "${GITHUB_SETUP_ASSETS_FOLDER}"
export DEV="true"
export HOST="127.0.0.1"
export API_URL="https://127.0.0.1/api"
export DATA_URL="https://127.0.0.1/data"
TARGET="${GITHUB_SETUP_ASSETS_FOLDER}/runtime-config.json"
SOURCE="${GITHUB_SETUP_ROOT}/.docker/front/runtime-config.json.template"
rm -f "${TARGET}"
touch "${TARGET}"
while IFS= read -r line; do
    eval "echo \"${line}\"" >> "${TARGET}"
done < "${SOURCE}"
chmod -R +r "${GITHUB_SETUP_ASSETS_FOLDER}"

npm install

echo > /dev/tty

echo 'Please add this AUTHENTICATION key on your github user' > /dev/tty
echo 'Even if you already add one, please add this one, it is a new one' > /dev/tty
echo '##### START #####' > /dev/tty
cat "${GITHUB_SETUP_SSH_FOLDER}/${GITHUB_SETUP_SSH_KEY}_auth.pub" > /dev/tty
echo '###### END ######' > /dev/tty

echo 'Please add this SIGNING key on your github user' > /dev/tty
echo 'Even if you already add one, please add this one, it is a new one' > /dev/tty
echo '##### START #####' > /dev/tty
cat "${GITHUB_SETUP_SSH_FOLDER}/${GITHUB_SETUP_SSH_KEY}_sign.pub" > /dev/tty
echo '###### END ######' > /dev/tty
