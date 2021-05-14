#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;
#include maps\mp\bots\_bot_utility;

init()
{
	thread tester();

	setDvarIfUninitialized( "bots_test", true );

	if (!getDvarInt("bots_test"))
		return;

	level thread onConnected();
}

tester()
{
	wait 0.5;

	// regression
	a = 801;
	if (a <= -800)
		a = 800;

	print(a); // 801

	// regression
	dir = "yo";
	r = 3;

	j = 0;
	while (j < 24)
	{
		a = 9;
		j++;
	}

	b = 2;

	print(dir); // yo
	print(r); // 3



	// test arg passing
	e = spawnStruct();
	e.a = 4;
	f = ::test_func;

	[[f]](e, 4); // test_func 4 4
	print(e.a); // 5

	test_func2(::test_func3, "hi"); // hi

	e.b = ::test_func3;
	[[e.b]]("ahaha"); // ahaha





	callbacksort = undefined;
	y = 0;

	switch ("kek")
	{
		case "lol":
				print("FUCKKKKKKKK");
			break;
		case "kek":
			print("HAHAHAHAHAAH");
			break;
	}
	
	switch(randomInt(3))
	{
		case 0:
			callbacksort = ::test_func;
			y = 1;
		break;
		case 1:
			callbacksort = ::test_func2;
			y = 1;
		break;
		case 2:
			callbacksort = ::test_func3;
			y = 1;
		break;
	}
	
	print(isDefined(callbacksort) + " " + y); // 1 1


	// test heap sorting
	sort = NewHeap(::ReverseHeap);
	sort HeapInsert(3);
	sort HeapInsert(4);
	sort HeapInsert(1);
	sort HeapInsert(3);
	sort HeapInsert(87);
	sort HeapInsert(-123);
	sort HeapInsert(0);

	str = "";

	while (sort.data.size)
	{
		str += sort.data[0] + ", ";
		sort HeapRemove();
	}

	print(str); // -123, 0, 1, 3, 3, 4, 87, 


	thread await();
	level waittill("aaaa", aa, bb, cc, dd);
	print(aa + " " + bb + " " + cc + " " + dd); // 1 2 3 4


	new_arr[0] = true;
	print(new_arr[0]); // 1



	level tet(); // OK


	level tet2(); // 0
}

tet2(a)
{
	print(isDefined(a));
}

tet()
{
	arr = [];

	arr[0] = self;

	print("OK");
}

await()
{
	wait 0.5;
	level notify("aaaa", 1, 2, 3, "4");
}

test_func(a, b)
{
	print("test_func " + b + " " + a.a);
	a.a += 1;
}

test_func2(a, b)
{
	[[a]](b);
}

test_func3(a)
{
	print(a);
}

onConnected()
{
	for (;;)
	{
		level waittill("connected", player);

		player thread test();
	}
}

test()
{
	self endon("disconnect");

	for (;;)
	{
		wait 0.05;

		if (self is_bot())
		{
		}
		else
		{
		}
	}
}
