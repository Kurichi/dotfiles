if status is-interactive
    # Commands to run in interactive sessions can go here
end

set -x DENO_INSTALL /home/kurichi/.deno
set -x PNPM_HOME /home/kurichi/.local/share/pnpm/

npx expose-wsl@latest

set -x REACT_NATIVE_PACKAGER_HOSTNAME (ipconfig.exe | grep -a 'IPv4' |  cut -d ':' -f 2 | sed 's/ //g' | sed -n -e '/^192/p')

