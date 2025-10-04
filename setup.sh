#!/bin/sh

echo 'Setting up your GitHub repository...' > /dev/tty
echo > /dev/tty

# Function to display start of a new part of the setup
gitSetupPart() {
    cols=$(tput cols)
    msg_len=$(printf "%s" "$1" | wc -c)
    count=$(( (cols - msg_len - 2) / 2 ))
    [ ${count} -lt 3 ] && count=3
    symbols=$(printf "%${count}s" "" | tr ' ' '#')
    extra=""
    [ $(( (cols - msg_len - 2) % 2 )) -ne 0 ] && extra="#"
    echo "\033[31m${symbols}\033[0m \033[1;31m$1\033[0m \033[31m${symbols}${extra}\033[0m" > /dev/tty
}

#########################################################################################################################################################################
#                                                                               VARIABLES                                                                               #
#########################################################################################################################################################################
gitSetupPart 'VARIABLES'

GITHUB_SETUP_ROOT="$(git rev-parse --show-toplevel)"
GITHUB_SETUP_SSH_FOLDER="${GITHUB_SETUP_ROOT}/.ssh"
GITHUB_SETUP_SSH_KEY='id_ed25519'
read -p "Your GitHub email: " GITHUB_SETUP_EMAIL > /dev/tty
read -p "Your GitHub pseudo: " GITHUB_SETUP_USER > /dev/tty

#########################################################################################################################################################################
#                                                                               GIT CONFIG                                                                              #
#########################################################################################################################################################################
gitSetupPart 'GIT CONFIG'
cd "${GITHUB_SETUP_ROOT}"

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

#########################################################################################################################################################################
#                                                                               GIT HOOKS                                                                               #
#########################################################################################################################################################################
gitSetupPart 'GIT HOOKS'
cd "${GITHUB_SETUP_ROOT}"

echo '#!/bin/sh

MSG_FILE="$1"
MSG=$(cat "$MSG_FILE")
BRANCH=$(git symbolic-ref --short HEAD)
TYPES="feat|fix|docs|style|refactor|perf|test|chore"
PATTERN="^(${TYPES})\(${BRANCH}\): .+"

if ! echo "${MSG}" | grep -Eq "${PATTERN}"; then
    echo "ERROR: Invalid commit message."
    echo "Your message must follow the format:"
    echo "<type>(<scope>): <comment>"
    echo "Where <type> is one of: ${TYPES}"
    echo "and <scope> must match your branch name: ${BRANCH}"
    echo "Example: feat(my-branch): add new feature"
    exit 1
fi' > "${GITHUB_SETUP_ROOT}/.git/hooks/commit-msg"
chmod +x "${GITHUB_SETUP_ROOT}/.git/hooks/commit-msg"

#########################################################################################################################################################################
#                                                                                SSH KEYS                                                                               #
#########################################################################################################################################################################
gitSetupPart 'SSH KEYS'
cd "${GITHUB_SETUP_ROOT}"

GITHUB_SETUP_SSH_FILES="${GITHUB_SETUP_SSH_FOLDER}/${GITHUB_SETUP_SSH_KEY}_auth ${GITHUB_SETUP_SSH_FOLDER}/${GITHUB_SETUP_SSH_KEY}_auth.pub ${GITHUB_SETUP_SSH_FOLDER}/${GITHUB_SETUP_SSH_KEY}_sign ${GITHUB_SETUP_SSH_FOLDER}/${GITHUB_SETUP_SSH_KEY}_sign.pub"
for file in ${GITHUB_SETUP_SSH_FILES}; do
    if [ ! -f "${file}" ]; then
        echo "Generating new SSH keys in ${GITHUB_SETUP_SSH_FOLDER}..." > /dev/tty
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

#########################################################################################################################################################################
#                                                                                 ASSETS                                                                                #
#########################################################################################################################################################################
gitSetupPart 'ASSETS'
cd "${GITHUB_SETUP_ROOT}"

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

#########################################################################################################################################################################
#                                                                              NPM INSTALL                                                                              #
#########################################################################################################################################################################
gitSetupPart 'NPM INSTALL'
cd "${GITHUB_SETUP_ROOT}"

npm install

#########################################################################################################################################################################
#                                                                                  END                                                                                  #
#########################################################################################################################################################################
gitSetupPart 'END'
cd "${GITHUB_SETUP_ROOT}"

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
