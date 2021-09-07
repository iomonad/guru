# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/Gottox/${PN}.git"
else
	KEYWORDS="~amd64"
	SRC_URI="https://github.com/Gottox/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
fi

DESCRIPTION="Simple markup - markdown like syntax"
HOMEPAGE="https://github.com/Gottox/smu"

LICENSE="MIT"
SLOT="0"

src_prepare() {
	default
	sed -i \
		-e '/^CFLAGS/ s|-g -O0 ||;s|-Werror ||;s|^CFLAGS =|CFLAGS +=|;' \
		-e '/^LDFLAGS/ s|^LDFLAGS =|LDFLAGS +=|' \
		config.mk || die "sed failed"
}

src_install() {
	emake PREFIX="${EPREFIX}/usr" DESTDIR="${ED}" install
	dodoc "documentation"
}
