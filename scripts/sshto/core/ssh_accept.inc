ssh_yes() {
# If connecting first time send 'yes' on ssh's request.
# Expect must be installed on server. Options:
#   $1 - ssh address with parameters(if needed)
#
# Usage example:
#   ssh_yes "-p22 user@localhost"
expect << EOF
spawn ssh $1
expect {
    "(yes/no)?" {
        send "yes\n"
        expect {
            "assword:" { exit }
            "$ "       { send "exit\n" }
        }
    }
    "assword:" { exit }
    "$ "       { send "exit\n" }
}
exit
EOF
}
