
// clang-format sorts includes unless SortIncludes: Never. However, the ordering
// does matter here. So, we need to disable clang-format for safety.

// clang-format off
#include <stdint.h>
#include <Rinternals.h>
#include <R_ext/Parse.h>
// clang-format on

#include "rust/api.h"

static uintptr_t TAGGED_POINTER_MASK = (uintptr_t)1;

SEXP handle_result(SEXP res_) {
    uintptr_t res = (uintptr_t)res_;

    // An error is indicated by tag.
    if ((res & TAGGED_POINTER_MASK) == 1) {
        // Remove tag
        SEXP res_aligned = (SEXP)(res & ~TAGGED_POINTER_MASK);

        // Currently, there are two types of error cases:
        //
        //   1. Error from Rust code
        //   2. Error from R's C API, which is caught by R_UnwindProtect()
        //
        if (TYPEOF(res_aligned) == CHARSXP) {
            // In case 1, the result is an error message that can be passed to
            // Rf_errorcall() directly.
            Rf_errorcall(R_NilValue, "%s", CHAR(res_aligned));
        } else {
            // In case 2, the result is the token to restart the
            // cleanup process on R's side.
            R_ContinueUnwind(res_aligned);
        }
    }

    return (SEXP)res;
}

SEXP savvy_turf_run_batch__impl(SEXP c_arg__x, SEXP c_arg__products, SEXP c_arg__fixed, SEXP c_arg__size, SEXP c_arg__keep_n) {
    SEXP res = savvy_turf_run_batch__ffi(c_arg__x, c_arg__products, c_arg__fixed, c_arg__size, c_arg__keep_n);
    return handle_result(res);
}

SEXP savvy_turf_search__impl(SEXP c_arg__x, SEXP c_arg__batch_sizes, SEXP c_arg__keep_n, SEXP c_arg__num_return, SEXP c_arg__use_swaps, SEXP c_arg__swap_top_n) {
    SEXP res = savvy_turf_search__ffi(c_arg__x, c_arg__batch_sizes, c_arg__keep_n, c_arg__num_return, c_arg__use_swaps, c_arg__swap_top_n);
    return handle_result(res);
}


static const R_CallMethodDef CallEntries[] = {
    {"savvy_turf_run_batch__impl", (DL_FUNC) &savvy_turf_run_batch__impl, 5},
    {"savvy_turf_search__impl", (DL_FUNC) &savvy_turf_search__impl, 6},
    {NULL, NULL, 0}
};

void R_init_y2turf(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);

    // Functions for initialization, if any.

}
