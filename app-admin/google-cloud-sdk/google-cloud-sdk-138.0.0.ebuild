EAPI=5
inherit bash-completion-r1

DESCRIPTION="Contains the command line interface to the Google Cloud Platform"
HOMEPAGE="https://cloud.google.com/sdk/"

DOWNLOAD_URI="https://dl.google.com/dl/cloudsdk/channels/rapid/downloads"
SRC_URI="
    amd64? (
        ${DOWNLOAD_URI}/${P}-linux-x86_64.tar.gz
    )
    x86? (
        ${DOWNLOAD_URI}/${P}-linux-x86.tar.gz
    )
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="bash-completion +doc kubectl"
RESTRICT="mirror installsources"

CDEPEND="
	dev-lang/python:2.7
"

DEPEND="${CDEPEND}"

RDEPEND="${CDEPEND}"

S="${WORKDIR}/${PN}"

src_install() {
	if use bash-completion ; then
		newbashcomp completion.bash.inc ${PN}
	fi

	local additional=""
	if use kubectl ; then
		additional="--additional-components kubectl"
	fi
	python2 "bin/bootstrapping/install.py"        \
		--usage-reporting=false                   \
		--disable-installation-options            \
		--path-update=false                       \
		--bash-completion=false 				  \
		${additional}  						      \
	|| die

	local dir="/opt/${PN}"
	insinto "${dir}"
	doins -r *
	fperms 755 "${dir}/bin/gcloud" "${dir}/bin/gsutil"
	dosym "${dir}/bin/gcloud" /usr/bin/gcloud
	dosym "${dir}/bin/gsutil" /usr/bin/gsutil
	
	if use kubectl ; then
		fperms 755 "${dir}/bin/kubectl"
		dosym "${dir}/bin/kubectl" /usr/bin/kubectl
	fi

	if use doc ; then
		dodoc README RELEASE_NOTES LICENSE
		local mandir="/usr/share"
		insinto "${mandir}"
		doins -r help/man
	fi
}

