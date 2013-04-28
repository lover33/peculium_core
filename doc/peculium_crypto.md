

# Module peculium_crypto #
* [Description](#description)
* [Function Index](#index)
* [Function Details](#functions)


       Bitcoin Cryptography Utilities.
__Authors:__ Alexander Færøy ([`ahf@0x90.dk`](mailto:ahf@0x90.dk)).
<a name="description"></a>

## Description ##
   ----------------------------------------------------------------------------<a name="index"></a>

## Function Index ##


<table width="100%" border="1" cellspacing="0" cellpadding="2" summary="function index"><tr><td valign="top"><a href="#hash-1">hash/1</a></td><td>Returns the double SHA256 checksum of a given input.</td></tr></table>


<a name="functions"></a>

## Function Details ##

<a name="hash-1"></a>

### hash/1 ###


<pre><code>
hash(X::iolist()) -&gt; binary()
</code></pre>

<br></br>


Returns the double SHA256 checksum of a given input.