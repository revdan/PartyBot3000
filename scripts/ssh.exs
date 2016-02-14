:ssh.start
{:ok, conn} = :ssh.connect(to_char_list(System.get_env("PARTY_BOT_SERVER_IP")), 22, [
      {:user, to_char_list(System.get_env("PARTY_BOT_SSH_USER"))},
      {:silently_accept_hosts, true},
      {:rsa_pass_phrase, to_char_list(System.get_env("PARTY_BOT_SSH_PASS"))},
      {:user_dir, to_char_list(System.get_env("PARTY_BOT_SSH_DIR"))}
    ], 10_000)

res = SSHEx.cmd! conn, 'ls /release'
IO.inspect res
