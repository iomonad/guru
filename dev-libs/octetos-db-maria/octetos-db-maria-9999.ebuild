# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools

MYPV="${PV/_alpha/-alpha}"
MYP="${PN}-${MYPV}"
DESCRIPTION="C++ library for Database Acces."
HOMEPAGE="https://github.com/azaeldevel/octetos-db-maria"
if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/azaeldevel/octetos-core.git"
else
	SRC_URI="https://github.com/azaeldevel/${PN}/archive/${MYPV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64"
fi

LICENSE="GPL-3"
SLOT="0"

DEPEND="
	dev-libs/octetos-db-abstract
	dev-db/mariadb-connector-c
"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MYP}"

src_prepare() {
	default
	eautoreconf -fi
}

src_configure() {
	econf --with-gentoo
}
