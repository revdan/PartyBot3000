:application.ensure_all_started(:ssh)

{:ok, conn} = :ssh.connect(to_char_list(System.get_env("PARTY_BOT_SERVER_IP")), 22, [
      {:user, to_char_list(System.get_env("PARTY_BOT_SSH_USER"))},
      {:silently_accept_hosts, true},
      {:rsa_pass_phrase, to_char_list(System.get_env("PARTY_BOT_SSH_PASS"))},
      {:user_dir, to_char_list(System.get_env("PARTY_BOT_SSH_DIR"))}
    ], 10_000)

vsn = PartyBot3000.Mixfile.project[:version]

server = System.get_env("PARTY_BOT_SERVER")
ssh_dir = System.get_env("PARTY_BOT_SSH_DIR")

IO.puts ssh_dir
IO.puts "deploying version #{inspect vsn}"


IO.puts """
░░░░░░░░░▄░░░░░░░░░░░░░░▄░░░░
░░░░░░░░▌▒█░░░░░░░░░░░▄▀▒▌░░░
░░░░░░░░▌▒▒█░░░░░░░░▄▀▒▒▒▐�░░
░░░░░░░▐▄▀▒▒▀▀▀▀▄▄▄▀▒▒▒▒▒▐░░░
░░░░░▄▄▀▒░▒▒▒▒▒▒▒▒▒█▒▒▄█▒▐░░░
░░░▄▀▒▒▒░░░▒▒▒░░░▒▒▒▀██▀▒▌░░░
░░▐▒▒▒▄▄▒▒▒▒░░░▒▒▒▒▒▒▒▀▄▒▒▌░░
░░▌░░▌█▀▒▒▒▒▒▄▀█▄▒▒▒▒▒▒▒█▒▐░░
░▐░░░▒▒▒▒▒▒▒▒▌██▀▒▒░░�▒▒▒▀▄▌░
░▌░▒▄██▄▒▒▒▒▒▒▒▒▒░░░░░░▒▒▒▒▌░
▀▒▀▐▄█▄█▌▄░▀▒▒░░░░░░░░░░▒▒▒▐░
▐▒▒▐▀▐▀▒░▄▄▒▄▒▒▒▒▒▒░▒░▒░▒▒▒▒▌
▐▒▒▒▀▀▄▄▒▒▒▄▒▒▒▒▒▒▒▒░▒░▒░▒▒▐░
░▌▒▒▒▒▒▒▀▀▀▒▒▒▒▒▒░▒░▒░▒░▒▒▒▌░
░▐▒▒▒▒▒▒▒▒▒▒▒�▒▒░▒░▒░▒▒▄▒▒▐░░
░░▀▄▒▒▒▒▒▒▒▒▒▒▒░▒░▒░▒▄▒▒▒▒▌░░
░░░░▀▄▒▒▒▒▒▒▒▒▒▒▄▄▄▀▒▒▒▒▄▀░░░
░░░░░░▀▄▄▄�▄▄▀▀▀▒▒▒▒▒▄▄▀░░░░░
░░░░░░░░░▒▒▒▒▒▒▒▒▒▒▀▀░░░░░░░░
WELCOME TO SERVER
"""

:timer.sleep 1000

System.cmd("rm", ["-rf", "party_bot_3000_*.tar.gz"])

System.cmd("tar", ["--exclude", ".git", "--exclude", "_build",
  "--exclude", "deps", "--exclude", "deps",
  "--exclude", "\"*.log\"",
  "--exclude", "\"*.log\"", "--exclude", "root@*",
  "-zcvf", "party_bot_3000_#{vsn}.tar.gz", "."])


IO.puts "copying to server"
System.cmd("scp", ["party_bot_3000_#{vsn}.tar.gz", "#{server}:"])

IO.puts "unzipping release"

untar = SSHEx.cmd! conn, ~c(tar -zxvf /root/party_bot_3000_#{vsn}.tar.gz -C /release)
IO.puts untar

IO.puts "getting deps"
deps = SSHEx.cmd! conn, 'cd /release && mix do deps.get, deps.compile'
IO.puts deps

IO.puts "making release"
rel = SSHEx.cmd! conn, 'MIX_ENV=prod mix release'
IO.puts rel

SSHEx.cmd! conn, ~c(cp rel/party_bot_3000/releases/#{vsn}/party_bot_3000.tar.gz /app)
SSHEx.cmd! conn, ~c(cd app && tar xzfv party_bot_3000.tar.gz)
run = SSHEx.cmd! conn, ~c(bin/party_bot_3000 upgrade #{vsn})
IO.puts run

