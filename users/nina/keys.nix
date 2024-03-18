# ok, so what's going on here?
# These are hardware key backed security keys.  This isn't a real private key, it's just a pointer to the
# location on the hardware key for the actual private key.  This does nothing without that hardware key.
# Don't panic.
{
  hosts = {
    "all" = {
    };
    "sarah" = {
      "github" = {
        pub = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIJ3irFjnNdb4EuLjzbl3i/kUz6Mcgo1qbI5f3yQ6qJFgAAAACnNzaDpnaXRodWI= ssh:github";
        priv = ''
          -----BEGIN OPENSSH PRIVATE KEY-----
          b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAUAAAABpzay1zc2
          gtZWQyNTUxOUBvcGVuc3NoLmNvbQAAACCd4qxY5zXW+BLi4825d4v5FM+jHIKNamyOX98k
          OqiRYAAAAApzc2g6Z2l0aHViAAAAgOcaGSvnGhkrAAAAGnNrLXNzaC1lZDI1NTE5QG9wZW
          5zc2guY29tAAAAIJ3irFjnNdb4EuLjzbl3i/kUz6Mcgo1qbI5f3yQ6qJFgAAAACnNzaDpn
          aXRodWIlAAAAEHa4rxEk4faiuLPmC/Dk+VIAAAAAAAAACm5pbmFAc2FyYWgB
          -----END OPENSSH PRIVATE KEY-----
        '';
      };
    };
    "tammy" = {
      "github" = {
        pub = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAINeykUubl4gOTqSHEl9wtHaBG9HvI5NJohIQ/bLQhag7AAAACnNzaDpnaXRodWI= nina@sarah";
        priv = ''
          -----BEGIN OPENSSH PRIVATE KEY-----
          b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAUAAAABpzay1zc2
          gtZWQyNTUxOUBvcGVuc3NoLmNvbQAAACDXspFLm5eIDk6khxJfcLR2gRvR7yOTSaISEP2y
          0IWoOwAAAApzc2g6Z2l0aHViAAAAgJP/s3iT/7N4AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW
          5zc2guY29tAAAAINeykUubl4gOTqSHEl9wtHaBG9HvI5NJohIQ/bLQhag7AAAACnNzaDpn
          aXRodWIlAAAAEGJlsji+U25OTx+wC9qxllIAAAAAAAAACm5pbmFAc2FyYWgB
          -----END OPENSSH PRIVATE KEY-----
        '';
      };
    };
    "laura" = {
      "github" = {
        pub = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIG5g/WtYRcIvzMDK2WA/s0slpRANkq7PonQvO1cJFPEdAAAACnNzaDpnaXRodWI= nina@sarah";
        priv = ''
          -----BEGIN OPENSSH PRIVATE KEY-----
          b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAUAAAABpzay1zc2
          gtZWQyNTUxOUBvcGVuc3NoLmNvbQAAACBuYP1rWEXCL8zAytlgP7NLJaUQDZKuz6J0LztX
          CRTxHQAAAApzc2g6Z2l0aHViAAAAgEduiMtHbojLAAAAGnNrLXNzaC1lZDI1NTE5QG9wZW
          5zc2guY29tAAAAIG5g/WtYRcIvzMDK2WA/s0slpRANkq7PonQvO1cJFPEdAAAACnNzaDpn
          aXRodWIlAAAAEC5SMq8aTePbcg6ycS6o0FQAAAAAAAAACm5pbmFAc2FyYWgB
          -----END OPENSSH PRIVATE KEY-----
        '';
      };
    };
  };
}
