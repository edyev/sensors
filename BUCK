load('//:subdir_glob.bzl', 'subdir_glob')

cxx_binary(
  name = 'basecamp_service',
  header_namespace = 'basecamp_service',
  headers = subdir_glob([
    ('basecamp_service/include', '**/*.hpp'),
  ]),
  srcs = glob([
    'basecamp_service/src/**/*.cpp',
  ]),
  deps = [
  ],
)