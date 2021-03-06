pkg_name=etcd
pkg_description="Distributed reliable key-value store for the most critical data of a distributed system"
pkg_origin=core
pkg_version="v3.3.10"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('Apache-2.0')
pkg_source="https://github.com/coreos/${pkg_name}/releases/download/${pkg_version}/${pkg_name}-${pkg_version}-linux-amd64.tar.gz"
pkg_upstream_url=https://github.com/coreos/etcd/
pkg_shasum=1620a59150ec0a0124a65540e23891243feb2d9a628092fb1edcc23974724a45
pkg_dirname="${pkg_name}-${pkg_version}-linux-amd64"
pkg_deps=(core/curl)
pkg_build_deps=(core/gnupg)
pkg_bin_dirs=(/usr/bin)
pkg_exports=(
  [client-port]=etcd-client-end
  [server-port]=etcd-server-end
)
pkg_exposes=(client-port server-port)
pkg_svc_user="root"
# pkg_svc_group="$pkg_svc_user"

do_download() {
  do_default_download

  download_file "https://github.com/coreos/${pkg_name}/releases/download/${pkg_version}/${pkg_name}-${pkg_version}-linux-amd64.tar.gz.asc" \
	        "${pkg_name}-${pkg_version}-linux-amd64.tar.gz.asc" \
                "cc4bdd4f0a83efa46a34b590544ba7bb3ad494d07d43cf3f85933b660b97638a"
  download_file "https://coreos.com/dist/pubkeys/app-signing-pubkey.gpg" \
	        "app-signing-pubkey.gpg" \
                "16b93904e4b3133fe4b5f95f46e3db998c3b2f9d9cee6d4c2eb531f98028bcb3"
}

do_verify() {
  do_default_verify

  verify_file "${pkg_name}-${pkg_version}-linux-amd64.tar.gz.asc" \
              "cc4bdd4f0a83efa46a34b590544ba7bb3ad494d07d43cf3f85933b660b97638a"
  verify_file "app-signing-pubkey.gpg" \
	      "16b93904e4b3133fe4b5f95f46e3db998c3b2f9d9cee6d4c2eb531f98028bcb3"

  # GPG verification
  build_line "Verifying ${pkg_name}-${pkg_version}-linux-amd64.tar.gz signature"
  GNUPGHOME=$(mktemp -d -p "$HAB_CACHE_SRC_PATH")
  gpg --import --keyid-format LONG "${HAB_CACHE_SRC_PATH}/app-signing-pubkey.gpg"
  gpg --batch --verify \
	"${HAB_CACHE_SRC_PATH}"/${pkg_name}-${pkg_version}-linux-amd64.tar.gz.asc \
        "${HAB_CACHE_SRC_PATH}"/${pkg_name}-${pkg_version}-linux-amd64.tar.gz
  rm -r "$GNUPGHOME"
  build_line "Signature verified for ${pkg_name}-${pkg_version}-linux-amd64.tar.gz"
}

do_build() {
  return 0
}

do_install() {
  if [ ! -f "$pkg_prefix/etc/nsswitch.conf" ]; then
     mkdir "$pkg_prefix/etc/"
     touch "$pkg_prefix/etc/nsswitch.conf"
     echo "hosts: files dns" > "$pkg_prefix/etc/nsswitch.conf"
  fi

  mkdir -p "${pkg_prefix}/var/lib/etcd"
  install -v -D "$HAB_CACHE_SRC_PATH/$pkg_dirname/etcd" "$pkg_prefix/usr/bin/etcd"
  install -v -D "$HAB_CACHE_SRC_PATH/$pkg_dirname/etcdctl" "$pkg_prefix/usr/bin/etcdctl"
}

do_strip() {
  return 0
}
