
CUNI Khresmoi MT Service installation instructions
==================================================

We assume that $VERSION is 'dev' or 'stable' and $USER is the user account
that will own and run the services (user 'khresmoi' by default).

Prerequisities:
========================

We assume Ubuntu 12.04 (but any Linux with all the required packages should be OK).
Before installing Khresmoi MT Services, you must have the following packages installed
(including dependencies):

* On the application server: `git`

* On workers: `git` `netcat` `python-dev`


Application server installation:
================================

* Prepare the needed resources in a separate directory (assuming `$USER/data/`) --
  Checkout the khresmoi-mt Git repository to `~$USER/data/git-$VERSION`:

  git clone http://redmine.ms.mff.cuni.cz/khresmoi-mt.git ~$USER/mt-$VERSION/git

* Install Python virtual environment to `~$USER/data/virtualenv`:
  Read, adjust, and run `install_virtualenv.sh` from this directory.

* Prepare default directories in `~$USER/mt-$VERSION`:

    mkdir -p ~$USER/mt-$VERSION/{config,logs}
    ln -s ~$USER/mt-$VERSION/git/appserver/src ~$USER/mt-$VERSION/appserver
    ln -s ~$USER/mt-$VERSION/git/scripts ~$USER/mt-$VERSION/scripts

* Adjust configuration in `~$USER/mt-$VERSION/config` according to 
  `~$USER/data/config-example`
  (The file `config_appserver.sh` can be copied as-is if using default directory schema,
  the file `appserver.cfg` must be adjusted for IPs and ports of the workers for the
  individual languages, as well as the application server port.)

* You may now run the application server via `~$USER/mt-$VERSION/scripts/run_appserver`.

Workers installation:
=====================

We assume that we have a shared directory accessible from all workers in e.g. 
`/mnt/share`, where Moses binaries and Python virtualenv will be put. 

This may be either on a NFS share, or accessible through SSH (rsync is used to
access it).

Prepare the needed resources in the shared directory:
-----------------------------------------------------

This must be done on a machine where the shared directory is directly accessible
(locally or through NFS).

* Install Moses to to `/mnt/share/moses-$VERSION` (according to Moses installation
  instructions).

* Install Python virtual environment to `/mnt/share/virtualenv`: 
  Read, adjust, and run `install_virtualenv.sh` from this directory.

Prepare configuration (do this for all workers):
------------------------------------------------

* Copy all required data from the shared directory and checkout the Git 
  repository + copy configuration examples from Git:
  Read, adjust, and run `prepare_worker.sh` from this directory.

* Copy the translation model to be used with Moses (or check out the
  automatic updates/model distribution feature below that is able to copy 
  required models from NFS share on machine startup).

  The models should be located in the `~$USER/mt-$VERSION/models` subdirectory 
  (called e.g. 'ende' for English-German translation).
  The Moses INI files may contain relative paths as the Moses binaries will be
  run from this directory.

* Adjust configuration in the `~$USER/mt-$VERSION/config` directory according
  to the used language pair and models (if only the language pair/model directory
  differs and you want to use automatic model distribution, skip this step).

Autostart and automatic updates
-------------------------------

* If you want the MT service to be checked periodically and restarted on fail,
  adjust the crontab of $USER according to the khresmoi.crontab file.

* If you need the MT service to be started and updated on the machine startup, 
  add the file `khresmoi` from this directory to `/etc/init.d` and link it to 
  the individual runlevels as the very last service to be started. Then prepare
  a directory for startup logs:

    cp /mnt/share/git-$VERSION/install/khresmoi /etc/init.d
    
    cd /etc/rc2.d; ln -s ../init.d/khresmoi S99z_khresmoi; 
    cd ..; for r in 3 4 5; do cp -P rc2.d/S99z_khresmoi rc$r.d; done
    cd /etc/rc6.d; ln -s ../init.d/khresmoi K99z_khresmoi; 
    cd ..; for r in 0 1; do cp -P rc6.d/K99z_khresmoi rc$r.d; done
    
    mkdir /var/log/khresmoi; chown khresmoi /var/log/khresmoi

  Please note that automatic updates are contained within the `khresmoi` init
  script. If you need initialization but no updates, comment out the corresponding
  lines.

* If you need automatic model distribution (to be checked with updates), place
  trained Moses models into `/mnt/share/models-$VERSION` and create the file
  `/mnt/share/index.cfg` that will contain the assignment of models to
  machines, in the form:

    <IP-or-hostname>:$VERSION:subpath

  E.g.: `192.168.1.10:stable:en-de` if the models to be used on `192.168.1.10`
  are located in `/mnt/share/models-stable/en-de`. 

  The model directories must contain `moses.ini` for translation model and 
  `recaser.moses.ini` for recasing  model; both files must contain 
  *relative* paths to other files. If you need to use a different setting, you
  must modify workers configuration in the `~$USER/mt-$VERSION/config` directory.

