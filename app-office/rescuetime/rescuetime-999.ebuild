# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit multilib unpacker systemd

DESCRIPTION="Data uploader for the RescueTime time tracker"
HOMEPAGE="https://www.rescuetime.com"
SRC_URI="
	amd64? (
		${HOMEPAGE}/installers/${PN}_current_amd64.deb
	)
	x86? (
		${HOMEPAGE}/installers/${PN}_current_i386.deb
	)
"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RDEPEND=">=dev-python/pygtk-2.14
		 >=dev-python/gnome-keyring-python-2"
DEPEND="${RDEPEND}"

S="${WORKDIR}"
src_unpack() {
	unpack_deb "${A}"
}

src_install() {
	dobin usr/bin/rescuetime
	newinitd "${FILESDIR}"/rescuetime.initd rescuetime
	newconfd "${FILESDIR}"/rescuetime.conf rescuetime
	systemd_newunit "${FILESDIR}"/rescuetime_at.service "rescuetime@.service"
}
