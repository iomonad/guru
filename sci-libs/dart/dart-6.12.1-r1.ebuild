# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{8..10} )

CMAKE_BUILD_TYPE="Release"

inherit cmake python-single-r1

DESCRIPTION="Dynamic Animation and Robotics Toolkit"
HOMEPAGE="
	https://dartsim.github.io
	https://github.com/dartsim/dart
"
SRC_URI="https://github.com/dartsim/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="bullet doc examples extras glut gui +ipopt +nlopt ode python test tests tutorials urdfdom
cpu_flags_x86_mmx cpu_flags_x86_mmxext	cpu_flags_x86_sse cpu_flags_x86_sse2 cpu_flags_x86_sse3
cpu_flags_x86_ssse3 cpu_flags_x86_sse4a cpu_flags_x86_sse4_1 cpu_flags_x86_sse4_2 cpu_flags_x86_avx
cpu_flags_x86_avx2 cpu_flags_x86_avx512dq cpu_flags_x86_avx512f cpu_flags_x86_avx512vl
cpu_flags_x86_3dnow cpu_flags_x86_3dnowext cpu_flags_ppc_vsx cpu_flags_ppc_vsx2 cpu_flags_ppc_vsx3
cpu_flags_ppc_altivec cpu_flags_arm_neon cpu_flags_arm_iwmmxt cpu_flags_arm_iwmmxt2 cpu_flags_arm_neon"
#TODO: pagmo

RDEPEND="
	app-arch/lz4
	>=dev-cpp/eigen-3.0.5
	dev-libs/boost
	dev-libs/tinyxml2
	>=sci-libs/libccd-2.0
	>=media-libs/assimp-3.0.0
	>=sci-libs/fcl-0.2.9
	sci-libs/flann
	sci-libs/octomap

	bullet? ( sci-physics/bullet )
	examples? (
		dev-cpp/tiny-dnn
		dev-libs/urdfdom
	)
	extras? ( dev-libs/urdfdom )
	glut? ( media-libs/freeglut )
	gui? (
		dev-games/openscenegraph
		media-libs/imgui:=[glut(-)?,opengl(-)]
		media-libs/lodepng:=
		virtual/opengl
		x11-libs/libXi
		x11-libs/libXmu
	)
	ipopt? ( sci-libs/ipopt )
	nlopt? ( >=sci-libs/nlopt-2.4.1 )
	ode? ( dev-games/ode )
	python? (
		${PYTHON_DEPS}
		$(python_gen_cond_dep 'dev-python/pybind11[${PYTHON_USEDEP}]')
	)
	urdfdom? ( dev-libs/urdfdom )
"
DEPEND="
	${RDEPEND}
	examples? ( dev-libs/urdfdom_headers )
	extras? (
		dev-cpp/gtest
		dev-libs/urdfdom_headers
	)
	test? ( dev-cpp/gtest )
	urdfdom? ( dev-libs/urdfdom_headers )
"
BDEPEND="
	app-text/dos2unix
	doc? ( app-doc/doxygen )
	test? ( python? ( $(python_gen_cond_dep 'dev-python/pytest[${PYTHON_USEDEP}]') ) )
"

RESTRICT="!test? ( test )"
PATCHES=(
	"${FILESDIR}/${P}-no-deprecated-examples.patch"
	"${FILESDIR}/${PN}-respect-ldflags.patch"
	"${FILESDIR}/${P}-respect-cflags.patch"
	"${FILESDIR}/${P}-use-system-gtest.patch"
	"${FILESDIR}/${P}-use-system-lodepng-imgui.patch"
)
REQUIRED_USE="
	examples? ( gui )
	gui? ( glut )
	python? (
		${PYTHON_REQUIRED_USE}
		gui
	)

	|| ( ipopt nlopt )
"

pkg_setup() {
	use python && python-single-r1_pkg_setup
}

src_prepare() {
	# delete bundled libs
	rm -r unittests/gtest || die
	rm -r dart/external/{imgui,lodepng} || die
	# delete deprecated examples
	rm -r examples/deprecated_examples || die
	dos2unix unittests/CMakeLists.txt || die
	cmake_src_prepare
}

src_configure() {
	local simd=OFF
	use cpu_flags_x86_mmx && simd=ON
	use cpu_flags_x86_mmxext && simd=ON
	use cpu_flags_x86_sse && simd=ON
	use cpu_flags_x86_sse2 && simd=ON
	use cpu_flags_x86_sse3 && simd=ON
	use cpu_flags_x86_ssse3 && simd=ON
	use cpu_flags_x86_sse4a && simd=ON
	use cpu_flags_x86_sse4_1 && simd=ON
	use cpu_flags_x86_sse4_2 && simd=ON
	use cpu_flags_x86_avx && simd=ON
	use cpu_flags_x86_avx2 && simd=ON
	use cpu_flags_x86_avx512dq && simd=ON
	use cpu_flags_x86_avx512f && simd=ON
	use cpu_flags_x86_avx512vl && simd=ON
	use cpu_flags_x86_3dnow && simd=ON
	use cpu_flags_x86_3dnowext && simd=ON
	use cpu_flags_ppc_vsx && simd=ON
	use cpu_flags_ppc_vsx2 && simd=ON
	use cpu_flags_ppc_vsx3 && simd=ON
	use cpu_flags_ppc_altivec && simd=ON
	use cpu_flags_arm_neon && simd=ON
	use cpu_flags_arm_iwmmxt && simd=ON
	use cpu_flags_arm_iwmmxt2 && simd=ON
	use cpu_flags_arm_neon && simd=ON

	export ODE_DIR="${EPREFIX}/usr"

	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=ON
		-DDART_CODECOV=OFF
		-DDART_VERBOSE=ON
		-DDART_TREAT_WARNINGS_AS_ERRORS=OFF

		-DDART_BUILD_EXTRAS=$(usex extras)
		-DDART_BUILD_GUI_OSG=$(usex gui)
		-DDART_ENABLE_SIMD="${simd}"
	)
	cmake_src_configure
}

src_compile() {
	cmake_src_compile
	use examples && cmake_build examples
	use python && cmake_build dartpy
	use test && cmake_build tests
	use tutorials && cmake_build tutorials
}

src_install() {
	cmake_src_install
	#TODO: python (?)
	if ! use examples ; then
		rm -rf "${ED}/usr/share/doc/dart/examples" || die
	fi
	if ! use tutorials ; then
		rm -rf "${ED}/usr/share/doc/dart/tutorials" || die
	fi
	if use examples || use tutorials ; then
		exeinto "/usr/libexec/${PN}"
		doexe "${BUILD_DIR}"/bin/*
	fi
#	use python && cmake_build install-dartpy
	mv "${ED}/usr/share/doc/dart/data" "${ED}/usr/share/${PN}" || die
	mv "${ED}"/usr/share/doc/dart/* "${ED}/usr/share/doc/${PF}" || die
	docompress -x "/usr/share/doc/${PF}"
}
