EAPI="5"

inherit bash-completion-r1

DESCRIPTION="Contains the command line interface to the Google Cloud Platform"
HOMEPAGE="https://cloud.google.com/sdk/"
SRC_URI="https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="go java php bash-completion +doc"
RESTRICT="mirror installsources"

CDEPEND="
	dev-lang/python:2.7
	go?   ( dev-lang/go:0 )
	java? ( >=virtual/jre-1.6 )
	php?  ( >=dev-lang/php-5 )"

DEPEND="${CDEPEND}"

RDEPEND="${CDEPEND}"

S="${WORKDIR}/${PN}"

src_install() {
	if use bash-completion ; then
		newbashcomp completion.bash.inc ${PN}
	fi

	python2 bin/bootstrapping/install.py          \
		--usage-reporting=false                   \
		--disable-installation-options            \
		--path-update=false                       \
		--bash-completion=false 				  \
	|| die

	local dir="/opt/${PN}"
	insinto "${dir}"
	doins -r *
	fperms 755 "${dir}/bin/gcutil" "${dir}/bin/gcloud" "${dir}/bin/gsutil" "${dir}/bin/kubectl"
	dosym "${dir}/bin/gcutil" /usr/bin/gcutil
	dosym "${dir}/bin/gcloud" /usr/bin/gcloud
	dosym "${dir}/bin/gsutil" /usr/bin/gsutil
	dosym "${dir}/bin/kubectl" /usr/bin/kubectl

	if use doc ; then
		dodoc README RELEASE_NOTES LICENSE
		local mandir="/usr/share"
		insinto "${mandir}"
		doins -r help/man
	fi
}

