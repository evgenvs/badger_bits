import
  bb_system, bb_os, sequtils, algorithm, strutils, bb_nake


proc test_not_nil() =
  var s: string
  do_assert s.is_nil
  s = ""
  do_assert(not s.is_nil)
  do_assert s.not_nil
  s = nil


proc test_dot_walks() =
  const
    dir = "dot_walk_dir_rec"
    good_rec_result = [
      "dot_walk_dir_rec/this_also",
      "dot_walk_dir_rec/this_yes",
      "dot_walk_dir_rec/valid_dir/a",
      "dot_walk_dir_rec/valid_dir/b"]
    bad_rec_result = [
      "dot_walk_dir_rec/.ignore_dir/invisible",
      "dot_walk_dir_rec/.ignore_dir/maybe_not",
      "dot_walk_dir_rec/.ignore_this_file",
      "dot_walk_dir_rec/this_also",
      "dot_walk_dir_rec/this_yes",
      "dot_walk_dir_rec/valid_dir/.ignore_this_file",
      "dot_walk_dir_rec/valid_dir/a",
      "dot_walk_dir_rec/valid_dir/b"]

    good_result = [
      "dot_walk_dir_rec/this_also",
      "dot_walk_dir_rec/this_yes",
      "dot_walk_dir_rec/valid_dir",
      ]

    bad_result = [
      "dot_walk_dir_rec/.ignore_dir",
      "dot_walk_dir_rec/.ignore_this_file",
      "dot_walk_dir_rec/this_also",
      "dot_walk_dir_rec/this_yes",
      "dot_walk_dir_rec/valid_dir",
      ]

  var list = to_seq(dir.dot_walk_dir_rec)
  list.sort(system.cmp)
  do_assert list == @good_rec_result
  do_assert list != @bad_rec_result
  list = to_seq(dir.walk_dir_rec)
  list.sort(system.cmp)
  do_assert list == @bad_rec_result
  do_assert list != @good_rec_result

  list = map_it(to_seq(dir.dot_walk_dir), string, it.path)
  list.sort(system.cmp)
  do_assert list == @good_result
  do_assert list != @bad_result

  list = map_it(to_seq(dir.walk_dir), string, it.path)
  list.sort(system.cmp)
  do_assert list != @good_result
  do_assert list == @bad_result


proc test_safe_object() =
  type Node = ref object
    child: Node
  var parent = Node(
    child: Node(
      child: Node(
        child: nil)))

  var a = parent?.child?.child
  var b = parent?.child?.child?.child
  var c = parent?.child?.child?.child?.child

  do_assert a != nil
  do_assert b == nil
  do_assert c == nil

proc test_safe_string() =
  var
    a: string
    b = "something"

  do_assert b.last == 'g'

  proc doStuff(s: string) =
    do_assert s.safe.len > 0, "You need to pass a non empty string!"
    echo "doStuff"

  echo "Testing safe strings"
  echo b.safe
  echo b.safe.len
  echo a.safe
  echo a.nil_echo
  echo a.safe.len
  try:
    a.doStuff
    quit "Hey, we meant to assert there"
  except AssertionError:
    echo "Tested assertion"

proc test_safe_seq() =
  var
    a: seq[string]
    b = @["a", "b"]

  do_assert b.last == "b"

  proc doStuff(s: seq[string]) =
    do_assert s.safe.len > 0, "You need to pass a non empty sequence!"
    echo "doStuff"

  echo "a: ", a.safe.join(", ")
  echo "a len: ", a.safe.len
  echo "b: ", b.safe.join(", ")
  echo "b len: ", b.safe.len
  try:
    a.doStuff
    quit "Hey, we meant to assert there"
  except AssertionError:
    echo "Tested assertion"


proc test_cp() =
  dist_dir.remove_dir
  dist_dir.create_dir

  let dest_nim = dist_dir/"file"
  cp("test_misc.nim", dest_nim)
  do_assert dest_nim.exists_file

  dist_dir.remove_dir
  let dest_dir = dist_dir/"temp"/"dot_walk_dir_rec2"
  cp("dot_walk_dir_rec", dest_dir)
  do_assert exists_file(dest_dir/"this_also")


proc test_shell() =
  dist_dir.create_dir
  when defined(macosx): test_shell "rm -R", dist_dir


proc test() =
  test_not_nil()
  test_dot_walks()
  test_safe_object()
  test_safe_string()
  test_safe_seq()
  test_cp()
  test_shell()
  echo "All tests run"


task default_task, "Runs tests by default": test()
when isMainModule: test()
