git clone -b f35 https://pagure.io/fedora-lorax-templates.git
mkdir ostree_repo
ostree init --repo=ostree_repo
rpm-ostree compose tree --repo=$(pwd)/ostree_repo $(pwd)/src/fedora-sodalite.yaml

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
                --add-template-var=ostree_install_ref=fedora/35/x86_64/sodalite \
                --add-template-var=ostree_update_ref=fedora/35/x86_64/sodalite \
                --add-template-var=flatpak_remote_name=fedora \
                --add-template-var=flatpak_remote_url=oci+https://registry.fedoraproject.org \
                --add-template-var=flatpak_remote_refs="runtime/org.fedoraproject.Platform/x86_64/f35 app/org.gnome.gedit/x86_64/stable" \
                --logfile=$(pwd)/lorax.log \
                --tmp=$(pwd)/temp \
                --rootfs-size=8 \
                $(pwd)/finished
