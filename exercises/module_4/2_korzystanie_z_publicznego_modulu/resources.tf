module "local_file" {
    source = "git::https://github.com/ArchitekturaIKontenery/poznajtf.git//modules/local_file?ref=1.1.0"

    is_sensitive = false
    content      = "Created from remote module!"
    filename     = "remote_file.txt"
}