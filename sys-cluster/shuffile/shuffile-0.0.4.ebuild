# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit cmake

DESCRIPTION="SHUFFILE Shuffle files between processes"
HOMEPAGE="https://github.com/ECP-VeloC/shuffile"
SRC_URI="https://github.com/ECP-VeloC/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="test"

RDEPEND="
	>=sys-cluster/KVTree-1.0.2[mpi]
	sys-libs/zlib
	virtual/mpi
"
DEPEND="${RDEPEND}"
BDEPEND="
	>=dev-util/cmake-2.8
"

PATCHES=( "${FILESDIR}/no-static-${PV}.patch" )
RESTRICT="test" # https://github.com/ECP-VeloC/shuffile/issues/18
