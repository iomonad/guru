# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit R-packages toolchain-funcs

DESCRIPTION='High Performance CommonMark and github markdown rendering in R'
KEYWORDS="~amd64"
LICENSE='BSD-2'

RDEPEND="${DEPEND}"

src_prepare() {
	tc-export AR
	R-packages_src_prepare
}
