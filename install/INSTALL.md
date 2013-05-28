
CUNI Khresmoi MT Service installation instructions
==================================================

We assume that $VERSION is 'dev' or 'stable' and $USER is the user account
that will own and run the services (user 'khresmoi' by default).

Prerequisities:
========================

We assume Ubuntu 12.04 (but any Linux with all the required packages should be OK).
Before installing Khresmoi MT Services, you must have the following packages installed:

* On the application server:

    <none>

* On workers:
 
    netcat


Application server installation:
========================

* Prepare the needed resources in a separate directory (assuming `$USER/data/`) --
  Checkout the khresmoi-mt Git repository to `~$USER/data/git-$VERSION`:

  git clone gitolite@redmine.ms.mff.cuni.cz:khresmoi-mt.git ~$USER/data/git-$VERSION

* Install Python virtual environment to `~$USER/data/virtualenv`:
  Read, adjust, and run `install_virtualenv.sh` from this directory.

* Prepare default directories in `~$USER/mt-$VERSION`:

  mkdir -p ~$USER/mt-$VERSION/{config,logs}
  ln -s ~$USER/data/git-$VERSION/appserver/src ~$USER/mt-$VERSION/appserver
  ln -s ~$USER/data/git-$VERSION/appserver/scripts ~$USER/mt-$VERSION/scripts

* Adjust configuration in `~$USER/mt-$VERSION` according to ~$USER/data/config-example
  (The file `config_appserver.sh` can be copied as-is if using default directory schema,
  the file `appserver.cfg` must be adjusted for IPs and ports of the workers for the
  individual languages, as well as the application server port.)

* You may now run the application server via `~$USER/mt-$VERSION/scripts/run_appserver`.

Workers installation:
========================

We assume that we have a NFS share accessible from all workers in /mnt/share
(if not, you must copy these resources to all workers).
Prepare the needed resources in the shared directory:

* Checkout the khresmoi-mt Git repository to /mnt/share/git-$VERSION:

  git clone gitolite@redmine.ms.mff.cuni.cz:khresmoi-mt.git /mnt/share/git-$VERSION

* Install Moses to to /mnt/share/moses-$VERSION

* Install Python virtual environment to /mnt/share/virtualenv: 
  Read, adjust, and run install_virtualenv.sh from this directory.

Prepare configuration (do this for all workers):

* Prepare directories by linking from the NFS share and copying configuration
  examples from Git:
  Read, adjust, and run link_dirs.sh from this directory.

* Copy the Moses translation and recasing models to a subdirectory of the
  ~$USER/mt-$VERSION/models directory (e.g. 'ende' for English-German
  translation).
  The Moses INI files may contain relative paths as the Moses binaries will be
  run from this directory.

* Adjust configuration in the ~$USER/mt-$VERSION/config directory according
  to the used language pair and models.

* If you need the MT service to be started on the machine startup, add the
  file khresmoi from this directory to /etc/init.d and link it to the individual runlevels
  as the very last service to be started. Then prepare a directory for startup logs:

  cp /mnt/share/git-$VERSION/install/khresmoi /etc/init.d

  cd /etc/rc2.d; ln -s ../init.d/khresmoi S99z_khresmoi; 
  cd ..; for r in 3 4 5; do cp -P rc2.d/S99z_khresmoi rc$r.d; done
  cd /etc/rc6.d; ln -s ../init.d/khresmoi K99z_khresmoi; 
  cd ..; for r in 0 1; do cp -P rc6.d/K99z_khresmoi rc$r.d; done

  mkdir /var/log/khresmoi; chown khresmoi /var/log/khresmoi

* If you want the MT service to be checked periodically and restarted on fail,
  adjust the crontab of $USER according to the khresmoi.crontab file.

