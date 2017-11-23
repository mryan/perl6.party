Containers and Variables of Perl 6

Having a rudimentary understanding of containers is vital for enjoyable programming in Perl 6. They're ubiquitous and not only do they affect the type of variables you get, but also the way `List`s and `Map`s behave when iterated.

Today, we'll learn the basics of what containers are and how to work with them, but first, I'd like you to temporarily forget *everything* you might know about Perl 6's sigils and variables, especially if you're coming from Perl 5's background. **Everything.**

## Show Me The Money

In Perl 6, a variable is prefixed with a `$` sigil and is given a value with
a binding operator (`:=`). Like so:

    my $foo := 42;
    say "The value is $foo"; # OUTPUT: «The value is 42␤»

If you've followed my suggestion to forget everything you know, it won't shock
you to learn the same applies to `List` and `Hash` types:

    my $ordered-things := <foo bar ber>;
    my $named-things   := %(:42foo, :bar<ber>);

    say "$named-things<foo> bottles of $ordered-things[2] on the wall";
    # OUTPUT: «42 bottles of ber on the wall␤»

    .say for $ordered-things;  # OUTPUT: «foo␤bar␤ber␤»
    .say for $named-things;    # OUTPUT: «bar => ber␤foo => 42␤»

Knowing just this, you can write a great variety of programs, so if you ever
start to feel like there's just too much to learn, remember you don't have to
learn everything at once.

## We Wish You a Merry Listmas

Let's try doing more things with our variables. It's not uncommon to want
to change a value in a list. How well do we fare?

    my $list := (1, 2, 3);
    $list[0] := 100;
    # OUTPUT: «Cannot use bind operator with this left-hand side […] »

Although we can bind to variables, if we attempt to bind to some value, we
get an error, regardless of whether it comes from a `List` or just, say, a
literal:

    1 := 100;
    # OUTPUT: «Cannot use bind operator with this left-hand side […] »

This is how `List`s manage to be immutable. However, T'is The Season and wishes do come true, so let's wish for a mutable `List`!

What we need to get a hold of is a `Scalar` object because the binding operator can work with it. As the name suggests, a `Scalar` holds one thing.
You can't instantiate a `Scalar` via `.new` method,
but we can get some of them by just declaring a lexical variable; don't need
to bother giving them names:

    my $list := (my $, my $, my $);
    $list[0] := 100;
    say $list; # OUTPUT: «(100 (Any) (Any))␤»

The `(Any)` in the output are the default values of the containers (on that, a bit later). It seems we managed to bind a value after `List`'s creation, did
we not? Indeed we did, but…

    my $list := (my $, my $, my $);
    $list[0] := 100;
    $list[0] := 200;
    # OUTPUT: «Cannot use bind operator with this left-hand side […] »

The binding operation *replaced* the `Scalar` container with a new value
(`100`), so if we try to bind again, we're back to square one, trying to bind
to a value instead of a container again.

We need a better tool for the job.

## That's Your Assignment

The binding operator has a cousin: the assignment operator (`=`). Instead of
replacing our `Scalar` containers with a binding operator, we'll use the
assignment operator to assign (or store) our values in the containers:

    my $list := (my $ = 1, my $ = 2, my $ = 3);
    $list[0] = 100;
    $list[0] = 200;
    say $list;
    # OUTPUT: «(200 2 3)␤»

Now, we can assign our original values, as well as replace them with other
values whenever we want to. We can even get funky and put different types on each of the containers:

    my $list := (my Int $ = 1, my Str $ = '2', my Rat $ = 3.0);
    $list[0] = 100; # OK!
    $list[1] = 42;  # Typecheck failure!

    # OUTPUT: «Type check failed in assignment;
    #    expected Str but got Int (42) […] »

That's somewhat indulgent, but there *is* one thing that could use a type-constaint: the `$list` variable. We'll constain it to the `Positional` role to ensure it can only hold `Positional` types, like `List` and `Array`:

    my Positional $list := (my $ = 1, my $ = '2', my $ = 3.0);

Don't know about you, but that looks awfully verbose to me. Luckily, Perl 6
has syntax to simplify it.

## Position@lly

First, let's get rid of the type constraint on the variable. In Perl 6, you
can use `@` instead of `$` as a sigil to say that you want the variable
type-constrained with role `Positional`:

    my @list := 42;
    # OUTPUT: «Type check failed in binding;
    #   expected Positional but got Int (42) […] »

Second, instead of parentheses to hold our `List`, we'll use square brackets.
This tells the compiler to create an `Array` instead of a `List`. Arrays are
mutable and they stick each item into a `Scalar` container, just like we did
manually in the previous section:

    my @list := [1, '2', 3.0];
    @list[0] = 100;
    @list[0] = 200;
    say @list;
    # OUTPUT: «[200 2 3]␤»

Our code became a lot shorter, but we can toss a couple more characters. Just
like assigning instead of binding to a `$`-sigiled variable gives you a
`Scalar` container for free, you can assign to `@`-sigiled variable to get
a free `Array`, so we can get rid of the square brackets altogether:

    my @list = 1, '2', 3.0;

Nice and concise.

Similar ideas are behind `%`- and `&`-sigiled variables. The `%` sigil implies
type constrain on `Associative` role and offers the same shortcuts for
assignment. The `&`-sigiled variables type constrain on `Callable` (I'm not avare of any user-relevant differences between assignment and binding here).

    my %hash = :42foo, :bar<ber>;
    say %hash;  # OUTPUT: «{bar => ber, foo => 42}␤»

    my &reversay = *.flip.say;
    reversay '6 lreP ♥ I'; # OUTPUT: «I ♥ Perl 6␤»


## The One and Only

Above I mentioned assigment to `$`-sigiled variables gives you a free `Scalar`
container and scalars contain just one thing… So what exactly happens if you
put a `List` into a `Scalar`? After all, it seems to not implode the Universe
when you try to do that:

    my  $listish = (1, 2, 3);
    say $listish; # OUTPUT: «(1 2 3)␤»

Such behaviour may make it seem that `Scalar` is a misnomer, but it *does*
actually treat the *entire* list as a single thing. We can observe the
difference in a couple of ways. Let's compare it to a `List` **bound** to
a `$`-sigiled variable (so no `Scalar` is involved):

    my $list := (1, 2, 3);
    say $list.perl;
    say "Item: $_" for $list;

    # OUTPUT:
    # (1, 2, 3)
    # Item: 1
    # Item: 2
    # Item: 3


    my $listish = (1, 2, 3);
    say $listish.perl;
    say "Item: $_" for $listish;

    # OUTPUT:
    # $(1, 2, 3)
    # Item: 1 2 3

The `.perl` method gaves us an extra insight and showed the second list with a `$` before it, to indicate it's containerized in a `Scalar`. More importantly,
when we iterated over our `Lists` with the `for` loop, the second `List`
resulted in just a single iteration: the entire `List`!