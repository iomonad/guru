# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{8,9} pypy3 )
inherit distutils-r1

DESCRIPTION="Bring your ZSH history to Fish shell"
HOMEPAGE="
	https://github.com/rsalmei/zsh-history-to-fish
	https://pypi.org/project/portio/
"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

DOCS=( README.md )
