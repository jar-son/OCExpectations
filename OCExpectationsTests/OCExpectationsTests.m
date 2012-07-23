// OCExpectations OCExpectationsTests.m
//
// Copyright © 2012, The OCCukes Organisation. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the “Software”), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED “AS IS,” WITHOUT WARRANTY OF ANY KIND, EITHER
// EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO
// EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES
// OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.
//
//------------------------------------------------------------------------------

#import "OCExpectationsTests.h"

#import <OCExpectations/OCExpectations.h>

@implementation OCExpectationsTests

- (void)testShouldEqualNoThrow
{
	// 1 + 1 should = 2
	STAssertNoThrow([@(1 + 1) should:be(@2)], nil);
}

- (void)testShouldEqualThrows
{
	// 1 should NOT = 2
	STAssertThrows([@1 should:[@2 equal]], nil);
}

- (void)testShouldNotEqualNoThrow
{
	// 1 should NOT = 2
	STAssertNoThrow([@1 shouldNot:equal(@2)], nil);
}

- (void)testShouldBeTrue
{
	// Yes should yes be! Sounds Shakespearean. Or in other words, yes should be
	// yes. However, you cannot easily construct matchers as you can with RSpec
	// in Ruby. In Objective-C, the receiver must always come first and the
	// language does not support modular mix-ins.
	STAssertNoThrow([@YES should:[@YES be]], nil);
	STAssertThrows([@NO should:[@YES be]], nil);
}

- (void)testShouldBeFalse
{
	STAssertNoThrow([@NO should:[@NO be]], nil);
	STAssertThrows([@YES should:[@NO be]], nil);
}

- (void)testNot
{
	STAssertEqualObjects(OCSpecNot(@NO), @YES, nil);
	STAssertEqualObjects(OCSpecNot(nil), @YES, nil);
	
	// In Ruby, the following would answer false. That is, Ruby expression !0
	// answers false. However, in Objective-C, @0 equals @NO. They are one and
	// the same thing: both integer numbers with value of zero. Hence negating
	// zero equates to negating NO, answering YES.
	STAssertEqualObjects(OCSpecNot(@0), @YES, nil);
	
	// Negating an object, any object, answers NO. Note that in Objective-C,
	// null is not nil, therefore a non-nil object answering NO.
	STAssertEqualObjects(OCSpecNot([NSNull null]), @NO, nil);
}

- (void)testNotNot
{
	STAssertEqualObjects(OCSpecNot(OCSpecNot(@NO)), @NO, nil);
	STAssertEqualObjects(OCSpecNot(OCSpecNot(@YES)), @YES, nil);
	STAssertEqualObjects(OCSpecNot(OCSpecNot(nil)), @NO, nil);
	STAssertEqualObjects(OCSpecNot(OCSpecNot([NSNull null])), @YES, nil);
}

- (void)testBeAKindOf
{
	STAssertNoThrow([@123 should:[NSStringFromClass([NSNumber class]) beAKindOf]], nil);
}

- (void)testEqualHasObjectiveCSemantics
{
	STAssertNoThrow([@"5" should:[@"5" equal]], nil);
	STAssertNoThrow([@5 should:[@5 equal]], nil);
}

- (void)testExpectationNotMetException
{
	// When an expectation fails, it throws an NSException named
	// OCExpectationNotMetException. Make sure that that proves true. Give it
	// something that will always fail: one divided by three should never be
	// 0.333; not unless the floating-point unit has very, very low precision.
	STAssertThrowsSpecificNamed([@(1/3.0) should:be(@0.333)], NSException, OCExpectationNotMetException, nil);
}

- (void)testYesShouldBeTrueNotFalse
{
	STAssertNoThrow([@YES should:be_true], nil);
	STAssertNoThrow([@YES shouldNot:be_false], nil);
}

- (void)testNoShouldBeFalseNotTrue
{
	STAssertNoThrow([@NO should:be_false], nil);
	STAssertNoThrow([@NO shouldNot:be_true], nil);
}

- (void)testNilShouldBeNil
{
	// In Objective-C, you cannot send messages to the nil literal. Sending [nil
	// should:aMatcher] using a literal nil fails at compile time: a "void *"
	// bad receiver type. However, you really can send to nil. You only have to
	// cast the nil to an id, that is, send [(id)nil should:aMatcher].
	STAssertNoThrow([(id)nil should:be_nil], nil);
}

- (void)testEqlVersusEqual
{
	STAssertNoThrow([@"hello" should:equal(@"hello")], nil);
	
	// You might expect the following to not throw. However, it throws. Due to
	// clever compiler optimisations, the two strings share the same
	// identity. Strings in Apple's Foundation frameworks are immutable
	// atoms. Sharing an identity is normal and expected.
	//
	//	STAssertNoThrow([@"hello" shouldNot:eql(@"hello")], nil);
	//
	STAssertThrows([@"hello" shouldNot:eql(@"hello")], nil);
	
	// Work around compiler optimisations and warnings by constructing a string
	// from a C string. That will create two equal but non-identical
	// strings. They should compare equal but should not be identical.
	NSString *hello = [NSString stringWithCString:"hello" encoding:NSUTF8StringEncoding];
	STAssertNoThrow([hello shouldNot:eql(@"hello")], nil);
	STAssertNoThrow([hello should:equal(@"hello")], nil);
}

- (void)testVersioning
{
	STAssertNotNil(OCExpectationsVersionString(), nil);
	STAssertTrue(strcmp(@encode(typeof(kOCExpectationsVersionString)), "^C") == 0, nil);
	STAssertTrue(strcmp(@encode(typeof(kOCExpectationsVersionNumber)), "d") == 0, nil);
}

@end
