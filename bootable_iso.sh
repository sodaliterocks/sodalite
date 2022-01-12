git clone -b f35 https://pagure.io/fedora-lorax-templates.git
mkdir ostree_repo
ostree init --repo=ostree_repo
rpm-ostree compose tree --repo=$(pwd)/ostree_repo $(pwd)/src/sodalite-base.yaml

exec lorax  --product=Fedora \
                --version=35 \
                --source=https://kojipkgs.fedoraproject.org/compose/35/latest-Fedora-35/compose/Everything/x86_64/os/ \
                --variant=Sodalite \
		--release=20220110 \
                --nomacboot \
                --volid=Fedora-Sodalite-x86_64-35 \
                --add-template=$(pwd)/fedora-lorax-templates/ostree-based-installer/lorax-configure-repo.tmpl \
                --add-template=$(pwd)/fedora-lorax-templates/ostree-based-installer/lorax-embed-repo.tmpl \
                --add-template=$(pwd)/fedora-lorax-templates/ostree-based-installer/lorax-embed-flatpaks.tmpl \
                --add-template-var=ostree_install_repo=file://$(pwd)/ostree_repo \
                --add-template-var=ostree_update_repo=https://ostree.zio.sh/repo \
                --add-template-var=ostree_osname=fedora \
                --add-template-var=ostree_oskey=fedora-35-sodalite \
                --add-template-var=ostree_install_ref=sodalite/stable/x86_64/base \
                --add-template-var=ostree_update_ref=sodalite/stable/x86_64/base \
                --add-template-var=flatpak_remote_name=flathub \
                --add-template-var=flatpak_remote_url=https://flathub.org/repo/flathub.flatpakrepo \
                --add-template-var=flatpak_remote_refs="runtime/org.gnome.Platform/x86_64/41 app/org.gnome.Epiphany/x86_64/stable" \
                --logfile=$(pwd)/lorax.log \
                --tmp=$(pwd)/temp \
                --rootfs-size=8 \
                $(pwd)/finished
