# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{8..10} )

inherit distutils-r1 meson-multilib

MY_PV=$(ver_cut 1-3)
[ -n "$(ver_cut 4)" ] && MY_PV_REV="-$(ver_cut 4)"

IMGUI_VER="1.81"
IMGUI_MESON_WRAP_VER="1"

DESCRIPTION="A Vulkan and OpenGL overlay for monitoring FPS, temperatures, CPU/GPU load and more."
HOMEPAGE="https://github.com/flightlessmango/MangoHud"

SRC_URI="
	https://github.com/flightlessmango/MangoHud/archive/v${MY_PV}${MY_PV_REV}.tar.gz -> ${P}.tar.gz
	https://github.com/ocornut/imgui/archive/v${IMGUI_VER}.tar.gz -> imgui-${IMGUI_VER}.tar.gz
	https://wrapdb.mesonbuild.com/v2/imgui_${IMGUI_VER}-${IMGUI_MESON_WRAP_VER}/get_patch -> imgui-${IMGUI_VER}-${IMGUI_MESON_WRAP_VER}-meson-wrap.zip
"

KEYWORDS="-* ~amd64 ~x86"

LICENSE="MIT"
SLOT="0"
IUSE="+dbus debug +X xnvctrl wayland video_cards_nvidia"

REQUIRED_USE="
	|| ( X wayland )
	xnvctrl? ( video_cards_nvidia )"

BDEPEND="
	app-arch/unzip
	dev-python/mako[${PYTHON_USEDEP}]
	dev-libs/spdlog
	dev-util/glslang
	>=dev-util/vulkan-headers-1.2
	media-libs/vulkan-loader[${MULTILIB_USEDEP}]
	media-libs/libglvnd[$MULTILIB_USEDEP]
	dbus? ( sys-apps/dbus[${MULTILIB_USEDEP}] )
	X? ( x11-libs/libX11[${MULTILIB_USEDEP}] )
	video_cards_nvidia? (
		x11-drivers/nvidia-drivers[${MULTILIB_USEDEP}]
		xnvctrl? ( x11-drivers/nvidia-drivers[static-libs] )
	)
	wayland? ( dev-libs/wayland[${MULTILIB_USEDEP}] )
"

RDEPEND="${BDEPEND}"

S="${WORKDIR}/MangoHud-${PV}"

src_unpack() {
	default
	[ -n "${MY_PV_REV}" ] && ( mv ${WORKDIR}/MangoHud-${MY_PV}${MY_PV_REV} ${WORKDIR}/MangoHud-${PV} || die )

	unpack imgui-${IMGUI_VER}.tar.gz
	unpack imgui-${IMGUI_VER}-${IMGUI_MESON_WRAP_VER}-meson-wrap.zip
	mv ${WORKDIR}/imgui-${IMGUI_VER} ${S}/subprojects/imgui || die
}

src_prepare() {
	default
	eapply "${FILESDIR}/mangonhud-0.6.6-meson-build.patch"
}

multilib_src_configure() {
	local emesonargs=(
		-Dappend_libdir_mangohud=false
		-Duse_system_spdlog=enabled
		-Duse_system_vulkan=enabled
		-Dinclude_doc=false
		$(meson_feature video_cards_nvidia with_nvml)
		$(meson_feature xnvctrl with_xnvctrl)
		$(meson_feature X with_x11)
		$(meson_feature wayland with_wayland)
		$(meson_feature dbus with_dbus)
	)
	meson_src_configure
}

pkg_postinst() {
	if ! use xnvctrl; then
		einfo ""
		einfo "If mangohud can't get GPU load, or other GPU information,"
		einfo "and you have an older Nvidia device."
		einfo ""
		einfo "Try enabling the 'xnvctrl' useflag."
		einfo ""
	fi
}
