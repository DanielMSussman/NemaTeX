# setup_test_fixture(
#     NAME Setup_TaggingTrip
#     FIXTURE_NAME TaggingTripFiles
#     ARGS "tagging_trip_test;-p;-c=0;--fmt=ua2plain"
#     OUT_FILE ${CMAKE_BINARY_DIR}/test_output/taggingtriptest.out
#     MOVE_SRC tagging_trip_test.pdf
#     MOVE_DST ${CMAKE_BINARY_DIR}/test_output/tagging_trip_test.pdf
# )
#
# setup_test_fixture(
#     NAME Setup_MathTagging
#     FIXTURE_NAME MathTaggingFiles
#     ARGS "math_tagging;-p;-c=0;--fmt=ua2plain"
#     OUT_FILE ${CMAKE_BINARY_DIR}/test_output/mathtagging.out
#     MOVE_SRC math_tagging.pdf
#     MOVE_DST ${CMAKE_BINARY_DIR}/test_output/math_tagging.pdf
# )
