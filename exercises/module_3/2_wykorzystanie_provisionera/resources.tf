resource "local_file" "file" {
  content  = "Hello, World!!!"
  filename = "hello.txt"

  provisioner "file" {
    source = "hello.txt"
    destination = "/tmp/hello.txt"

    connection {
        type     = "ssh"
        user     = "root"
        password = "1234"
        host     = "localhost"
    }
  }
}

resource "local_file" "file2" {
  content  = "Hello, World"
  filename = "hello2.txt"

  provisioner "local-exec" {
    command = "echo %DATA1% %DATA2% >> env_vars.txt"

    environment = {
      DATA1 = "bar"
      DATA2 = 1
    }
  }
}

resource "local_file" "file2" {
  content  = "Hello, World"
  filename = "hello2.txt"

  provisioner "file" {
    source      = "script.sh"
    destination = "/tmp/script.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/script.sh",
      "/tmp/script.sh args",
    ]
  }
}
