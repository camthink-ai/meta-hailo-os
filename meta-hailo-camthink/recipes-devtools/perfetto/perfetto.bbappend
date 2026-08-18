strip_x86_assumptions() {
    for f in $(find ${B} -name '*.ninja'); do
        sed -i -E \
            -e 's/ -m(bmi|bmi2|avx|avx2|popcnt|sse[0-9.]*|fma|f16c|aes|pclmul|rdrnd)//g' \
            "$f"
    done

    for h in $(find ${B} -name perfetto_build_flags.h); do
        sed -i -E \
            's/PERFETTO_BUILDFLAG_DEFINE_PERFETTO_X64_CPU_OPT\(\) \([01]\)/PERFETTO_BUILDFLAG_DEFINE_PERFETTO_X64_CPU_OPT() (0)/g' \
            "$h"
    done
}

do_configure:append() {
    strip_x86_assumptions
}

do_compile:prepend() {
    strip_x86_assumptions
}
