/************************************************************** ggt-head beg
 *
 * GGT: Generic Graphics Toolkit
 *
 * Original Authors:
 *   Allen Bierbaum
 *
 * -----------------------------------------------------------------
 * File:          $RCSfile: PlaneTest.h,v $
 * Date modified: $Date: 2002-05-20 22:39:23 $
 * Version:       $Revision: 1.18 $
 * -----------------------------------------------------------------
 *
 *********************************************************** ggt-head end */
/*************************************************************** ggt-cpr beg
*
* GGT: The Generic Graphics Toolkit
* Copyright (C) 2001,2002 Allen Bierbaum
*
* This library is free software; you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public
* License as published by the Free Software Foundation; either
* version 2.1 of the License, or (at your option) any later version.
*
* This library is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
* Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public
* License along with this library; if not, write to the Free Software
* Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
*
 ************************************************************ ggt-cpr end */
#include <iostream>

#include <cppunit/TestCase.h>
#include <cppunit/TestSuite.h>
#include <cppunit/TestCaller.h>

#include <gmtl/Plane.h>

namespace gmtlTest
{

class PlaneTest : public CppUnit::TestCase
{
public:
   PlaneTest( std::string name = "PlaneTest")
   : CppUnit::TestCase (name)
   {;}

   virtual ~PlaneTest()
   {}

   virtual void setUp()
   {
      origin.set( 0,0,0 );
      x1_v.set( 1,0,0 );
      y1_v.set( 0,1,0 );
      z1_v.set( 0,0,1 );
      x1_pt.set( 1,0,0 );
      y1_pt.set( 0,1,0 );
      z1_pt.set( 0,0,1 );
      xy_plane = gmtl::Plane<float>(origin,x1_pt,y1_pt);
      zx_plane = gmtl::Plane<float>(origin,z1_pt,x1_pt);
      yz_plane = gmtl::Plane<float>(origin,y1_pt,z1_pt);
   }

   virtual void tearDown()
   {;}

   // ------------------------
   // CREATION TESTS
   // ------------------------
   void testCreation();
   void testThreePtCreation();
   void testNormPtCreation();
   void testNormOffsetCreation();
   void testCopyConstruct();

   // --------------------------
   // Comparison tests
   // --------------------------
   void testEqualityCompare();
   void testIsEqual();

   // --------------------------
   // Operations tests
   // --------------------------
   void testDistance();
   void testWhichSide();
   void testFindNearestPt();


   static CppUnit::Test* suite()
   {
      CppUnit::TestSuite* test_suite = new CppUnit::TestSuite ("PlaneTest");
      test_suite->addTest( new CppUnit::TestCaller<PlaneTest>("testCreation", &PlaneTest::testCreation));
      test_suite->addTest( new CppUnit::TestCaller<PlaneTest>("testThreePtCreation", &PlaneTest::testThreePtCreation));
      test_suite->addTest( new CppUnit::TestCaller<PlaneTest>("testNormPtCreation", &PlaneTest::testNormPtCreation));
      test_suite->addTest( new CppUnit::TestCaller<PlaneTest>("testNormOffsetCreation", &PlaneTest::testNormOffsetCreation));
      test_suite->addTest( new CppUnit::TestCaller<PlaneTest>("testCopyConstruct", &PlaneTest::testCopyConstruct));
      test_suite->addTest( new CppUnit::TestCaller<PlaneTest>("testEqualityCompare", &PlaneTest::testEqualityCompare));
      test_suite->addTest( new CppUnit::TestCaller<PlaneTest>("testIsEqual", &PlaneTest::testIsEqual));
      test_suite->addTest( new CppUnit::TestCaller<PlaneTest>("testDistance", &PlaneTest::testDistance));
      test_suite->addTest( new CppUnit::TestCaller<PlaneTest>("testWhichSide", &PlaneTest::testWhichSide));
      test_suite->addTest( new CppUnit::TestCaller<PlaneTest>("testFindNearestPt", &PlaneTest::testFindNearestPt));

      return test_suite;
   }

   static CppUnit::Test* interactiveSuite()
   {
      CppUnit::TestSuite* test_suite = new CppUnit::TestSuite ("PlaneTestInteractive");
      //test_suite->addTest( new CppUnit::TestCaller<ThreadTest>("interactiveCPUGrind", &ThreadTest::interactiveTestCPUGrind));
      return test_suite;
   }

protected:
   gmtl::Point<float, 3> origin;
   gmtl::Point<float, 3> x1_pt;
   gmtl::Point<float, 3> y1_pt;
   gmtl::Point<float, 3> z1_pt;
   gmtl::Vec<float, 3> x1_v;
   gmtl::Vec<float, 3> y1_v;
   gmtl::Vec<float, 3> z1_v;

   gmtl::Plane<float> xy_plane;
   gmtl::Plane<float> zx_plane;
   gmtl::Plane<float> yz_plane;
};

} // namespace gmtlTest
