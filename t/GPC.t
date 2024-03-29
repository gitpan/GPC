#!/usr/bin/jperl

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

use Test;
use strict;
BEGIN {plan tests => 9};

eval {require GPC; return 1};
ok ($@,'');
croak() if $@;
use GPC;

################################################################################
# create gpc object
my $contour1 = GPC::new_gpc_polygon();
my $contour2 = GPC::new_gpc_polygon();
ok ($contour1 && $contour2);

GPC::gpc_polygon_num_contours_set($contour1,1);
GPC::gpc_polygon_num_contours_set($contour2,1);
my $count1 = GPC::gpc_polygon_num_contours_get($contour1);
my $count2 = GPC::gpc_polygon_num_contours_get($contour2);
ok ($count1 == 1 && $count2 == 1);

my $hole_array1 = GPC::int_array(1);
my $hole_array2 = GPC::int_array(1);
GPC::gpc_polygon_hole_set($contour1,$hole_array1);
GPC::gpc_polygon_hole_set($contour2,$hole_array2);
GPC::int_set($hole_array1,0,0);
GPC::int_set($hole_array2,0,0);
$hole_array1 = GPC::gpc_polygon_hole_get($contour1);
$hole_array2 = GPC::gpc_polygon_hole_get($contour2);
$count1 = GPC::int_get($hole_array1,0);
$count2 = GPC::int_get($hole_array2,0);
ok ($count1 == 0 && $count2 == 0);

my @poly1 = ([1,1],[1,3],[3,3],[3,1]);
my @poly2 = ([2,2],[2,4],[4,4],[4,2]);
my $vlist1 = GPC::new_gpc_vertex_list();
my $vlist2 = GPC::new_gpc_vertex_list();
ok ($vlist1 && $vlist2);

my @gpc_vertexlist;
my $va;
my $vl;
@gpc_vertexlist = ();
foreach my $vertex (@poly1) {
  my $v = GPC::new_gpc_vertex();
  GPC::gpc_vertex_x_set($v,$$vertex[0]);
  GPC::gpc_vertex_y_set($v,$$vertex[1]);
  push @gpc_vertexlist,$v;
}
$va = create_gpc_vertex_array(@gpc_vertexlist);
$vl = GPC::new_gpc_vertex_list();
GPC::gpc_vertex_list_vertex_set($vl,$va);
GPC::gpc_vertex_list_num_vertices_set($vl,scalar(@poly1));
GPC::gpc_vertex_list_set($vlist1,0,$vl);
GPC::gpc_polygon_contour_set($contour1,$vlist1);
@gpc_vertexlist = ();
foreach my $vertex (@poly2) {
  my $v = GPC::new_gpc_vertex();
  GPC::gpc_vertex_x_set($v,$$vertex[0]);
  GPC::gpc_vertex_y_set($v,$$vertex[1]);
  push @gpc_vertexlist,$v;
}
$va = create_gpc_vertex_array(@gpc_vertexlist);
$vl = GPC::new_gpc_vertex_list();
GPC::gpc_vertex_list_vertex_set($vl,$va);
GPC::gpc_vertex_list_num_vertices_set($vl,scalar(@poly2));
GPC::gpc_vertex_list_set($vlist2,0,$vl);
GPC::gpc_polygon_contour_set($contour2,$vlist2);

$vlist1 = GPC::gpc_polygon_contour_get($contour1);
$vl     = GPC::gpc_vertex_list_get($vlist1,0);
$count1 = GPC::gpc_vertex_list_num_vertices_get($vl);
$vlist2 = GPC::gpc_polygon_contour_get($contour2);
$vl     = GPC::gpc_vertex_list_get($vlist2,0);
$count2 = GPC::gpc_vertex_list_num_vertices_get($vl);
ok ($count1 == 4 && $count2 == 4);

my $result = GPC::new_gpc_polygon();
GPC::gpc_polygon_clip(3,$contour1,$contour2,$result);
ok ($result);

$vlist1 = GPC::gpc_polygon_contour_get($result);
$vl     = GPC::gpc_vertex_list_get($vlist1,0);
$count1 = GPC::gpc_vertex_list_num_vertices_get($vl);
ok ($count1 == 8);

$va = GPC::gpc_vertex_list_vertex_get($vl);
my @expected = ([4,2],[3,2],[3,1],[1,1],[1,3],[2,3],[2,4],[4,4]);
my $error;
for (my $j = 0 ; $j < $count1 ; $j++) {
  my $v = GPC::gpc_vertex_get($va,$j);
  my $x = GPC::gpc_vertex_x_get($v);
  my $y = GPC::gpc_vertex_y_get($v);
  if ($x != $expected[$j][0] || $y != $expected[$j][1]) {
    $error = 1;
  }
}
ok (! $error);

################################################################################

sub create_gpc_vertex_array {
  my $len = scalar(@_);
  my $va = GPC::gpc_vertex_array($len);
  for (my $i=0; $i<$len; $i++) {
    my $val = shift;
    GPC::gpc_vertex_set($va,$i,$val);
  }
  return $va;
}

