# pmacsSSHFS
Convenience script to mount cluster directories on a local machine

# Installation

The script needs to be edited, replace

```
server=""
```

with

```
server="user@host"
```

I recommend using "transfer" as the host.


# Dependencies

Requires sshfs.

## sshfs installation on Mac OS

Install osxfuse then install sshfs. Because this involves a kernel extension and
can be tricky to debug, I recommend getting the released installer from
https://osxfuse.github.io. Download both FUSE and sshfs.

Do a default install of FUSE first, with the preferences pane but without the
legacy support. Then you will have to enable the extension by going to the
security preferences as prompted.

Next, install the sshfs package. After this, you should have the sshfs command
in the terminal.

I highly recommend turning off creation of `.DS_Store` on mounted volumes with

```
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool TRUE 
```

# Using sshfs

The sshfs protocol uses sftp to retrieve files on the remote server. Because of
the encryption overhead, and because it's actually doing lots of sftp commands
under the hood, it's slower than an NFS mount. The default command allows
caching, which improves performance but can lead to a delay between saving a
file on your local disk and it appearing changed on the server.

I use it for editing code and viewing files with Preview (eg, PDFs), Safari
(html prep output) or ITK-SNAP. I/O intensive jobs with many files (such as git
operations) are best done server side.

If you need to transfer or QC a lot of data, I recommend copying with rsync.
