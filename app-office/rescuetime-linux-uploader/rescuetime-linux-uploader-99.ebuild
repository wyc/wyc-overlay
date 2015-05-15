# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils distutils mozextension

DESCRIPTION="Data uploader for the RescueTime time tracker"
HOMEPAGE="https://launchpad.net/rescuetime-linux-uploader"
SRC_URI="${HOMEPAGE}/trunk/${PV}/+download/${P}.tar.bz2"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="epiphany firefox"
RDEPEND="epiphany? ( www-client/epiphany-extensions )
	firefox? (
		|| (
			>=www-client/mozilla-firefox-bin-1.5.0.7
			>=www-client/mozilla-firefox-1.5.0.7
		)
	)
	>=dev-python/pygtk-2.14"
DEPEND="${RDEPEND}"

src_unpack() {
	distutils_src_unpack

	# The setup.py does copying straight to /. We'll handle this stuff 
	# by hand later, because I couldn't figure out how to access the 
	# --root argument from that point.
	sed -i \
		-e "s~[[:alnum:]].*gnome_applet/rescuetime_16.png.*~pass~" \
		-e "/shutil.copy/d" \
		"${S}"/setup.py

	# Uploading fails because the URL changed. Patch from
	# https://answers.launchpad.net/rescuetime-linux-uploader/+question/50226
#	epatch "${FILESDIR}"/90-fix-uploads.patch
}

src_install() {
	distutils_src_install

	local i
	for i in {16,22,32,48}; do
		insinto /usr/share/icons/hicolor/${i}x${i}
		newins "${S}"/gnome_applet/rescuetime_${i}.png rescuetime.png || die
	done
	insinto /usr/share/pixmaps
	newins "${S}"/gnome_applet/rescuetime_48.png rescuetime.png || die
	insinto /usr/$(get_libdir)/bonobo/servers/
	doins "${S}"/gnome_applet/*.server || die

	if use firefox; then
		# Extension code derived from noscript ebuild
		declare MOZILLA_FIVE_HOME

		# If this <em:id> line is present, xpi_install() breaks
		sed -i -e "/rescuetime@angushelm.com/d" \
			"${S}"/firefox_extension/install.rdf || die

		if has_version '>=www-client/mozilla-firefox-1.5.0.7'; then
			MOZILLA_FIVE_HOME="/usr/$(get_libdir)/mozilla-firefox"
			xpi_install "${S}"/firefox_extension
		fi
		if has_version '>=www-client/mozilla-firefox-bin-1.5.0.7'; then
			MOZILLA_FIVE_HOME="/opt/firefox"
			xpi_install "${S}"/firefox_extension
		fi
	fi

	if use epiphany; then
		pushd "${S}"/epiphany_extension 2>/dev/null
		insinto /usr/$(get_libdir)/epiphany/*/extensions
		doins rescuetime.* || die
		popd 2>/dev/null
	fi
}

pkg_postinst() {
	distutils_pkg_postinst

	elog "To use the GNOME applet, add it to your panel."

	if use epiphany; then
		elog "To use the Epiphany plugin, first restart Epiphany."
		elog "Then go to Tools->Extensions and check the RescueTime extension."
	fi
}
