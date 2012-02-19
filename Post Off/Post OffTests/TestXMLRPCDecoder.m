//
//  TestXMLRPCDecoder.m
//  Post Off
//
//  Created by René on 23/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TestXMLRPCDecoder.h"

@implementation TestXMLRPCDecoder

// All code under test must be linked into the Unit Test bundle
- (void)testMath
{
    STAssertTrue((1 + 1) == 2, @"Compiler isn't feeling well today :-(");
}

- (void)setUp{
	
    [super setUp];
    
	NSLog(@"----------------");
	NSLog(@"Test Struct");
	
    // Set-up code here.
}

- (void)tearDown{
	
    [super tearDown];
	// Tear-down code here.
	NSLog(@"----------------");
    [p release];

}

- (void) testErrorResponse{
	
	NSString *s=@"<?xml version=\"1.0\"?> <methodResponse>   <fault>     <value>       <struct>         <member>           <name>faultCode</name>           <value><int>403</int></value>         </member>         <member>           <name>faultString</name>           <value><string>Combinación de usuario/contraseña errónea.</string></value>         </member>       </struct>     </value>   </fault> </methodResponse>";
	
	NSLog(@"%s", (char*)_cmd);
	NSLog(@"----------------");
	
	NSData *d = [s dataUsingEncoding:NSUTF8StringEncoding];
	
	p = [[XMLRPCDecoder alloc] initWithData:d];
	
	id u = [p decode];
	
	NSLog(@"El objeto recibido es: %@", [u class]);
	
	NSDictionary *a = u;
	
	STAssertTrue([a isKindOfClass:[NSDictionary class]], @"El objeto \"a\" debería ser un NSDictionary");
	STAssertNotNil(a, @"El objeto devuelto no debería ser Nil");
	
	value= [a objectForKey:@"faultCode"];
	
	STAssertNotNil(value, @"El objeto devuelto no debería ser Nil");
	
	value = [a objectForKey:@"faultString"];
	
	STAssertTrue([value isEqualToString:@"Combinación de usuario/contraseña errónea."],@"Debería ser 'Combinación de usuario/contraseña errónea.'(%@)", [di objectForKey:@"faultString"]);
}

- (void)testParseRecentPosts{
	
	NSString *s=@"<?xml version=\"1.0\"?> <methodResponse>   <params>     <param>       <value>       <array>         <data>          <value>            <struct>              <member><name>dateCreated</name><value><dateTime.iso8601>20110215T19:39:27</dateTime.iso8601></value></member>              <member><name>userid</name><value><string>1</string></value></member>              <member><name>postid</name><value><string>72</string></value></member>              <member><name>description</name><value><string>Guía médica del Principado de Asturias.</string></value></member>              <member><name>title</name><value><string>Guía Sanitaria de Asturias</string></value></member>              <member><name>link</name><value><string>http://renefernandez.com/2011/02/guia-sanitaria-de-asturias/</string></value></member>              <member><name>permaLink</name><value><string>http://renefernandez.com/2011/02/guia-sanitaria-de-asturias/</string></value></member>              <member><name>categories</name>                <value>                 <array>                   <data>                     <value><string>Páginas Web</string></value>                     <value><string>Work</string></value>                   </data>                 </array>                </value>               </member>               <member><name>mt_excerpt</name><value><string></string></value></member>               <member><name>mt_text_more</name><value><string></string></value></member>               <member><name>mt_allow_comments</name><value><int>0</int></value></member>               <member><name>mt_allow_pings</name><value><int>0</int></value></member>               <member><name>mt_keywords</name><value><string></string></value></member>               <member><name>wp_slug</name><value><string>guia-sanitaria-de-asturias</string></value></member>               <member><name>wp_password</name><value><string></string></value></member>               <member><name>wp_author_id</name><value><string>1</string></value></member>               <member><name>wp_author_display_name</name><value><string>René</string></value></member>               <member><name>date_created_gmt</name><value><dateTime.iso8601>20110215T19:39:27</dateTime.iso8601></value></member>               <member><name>post_status</name><value><string>publish</string></value></member>               <member><name>custom_fields</name>                 <value>                   <array>                     <data>                       <value>                         <struct>                           <member><name>id</name><value><string>122</string></value></member>                           <member><name>key</name><value><string>cliente</string></value></member>                           <member><name>value</name><value><string>El Comercio Digital</string></value></member>                         </struct>                       </value>                       <value>                         <struct>                           <member><name>id</name><value><string>125</string></value></member>                           <member><name>key</name><value><string>compania</string></value></member>                           <member><name>value</name><value><string>El Comercio Digital</string></value></member>                         </struct>                       </value>                       <value><struct>   <member><name>id</name><value><string>128</string></value></member>   <member><name>key</name><value><string>imagen</string></value></member>   <member><name>value</name><value><string>http://renefernandez.com/wp-content/uploads/2011/02/guia-sanitaria-asturias1.jpg</string></value></member> </struct></value>   <value><struct>   <member><name>id</name><value><string>124</string></value></member>   <member><name>key</name><value><string>link</string></value></member>   <member><name>value</name><value><string>http://proyectos.elcomerciodigital.com/guia-sanitaria-asturias/</string></value></member> </struct></value>   <value><struct>   <member><name>id</name><value><string>123</string></value></member>   <member><name>key</name><value><string>tecnologia</string></value></member>   <member><name>value</name><value><string>PHP + JS + JQuery + Wordpress + HTML + CSS/CSS3</string></value></member> </struct></value>   <value><struct>   <member><name>id</name><value><string>120</string></value></member>   <member><name>key</name><value><string>_edit_last</string></value></member>   <member><name>value</name><value><string>1</string></value></member> </struct></value>   <value><struct>   <member><name>id</name><value><string>121</string></value></member>   <member><name>key</name><value><string>_edit_lock</string></value></member>   <member><name>value</name><value><string>1297798879</string></value></member> </struct></value> </data></array></value></member>   <member><name>wp_post_format</name><value><string>standard</string></value></member> </struct></value>   <value><struct>   <member><name>dateCreated</name><value><dateTime.iso8601>20101213T09:48:26</dateTime.iso8601></value></member>   <member><name>userid</name><value><string>1</string></value></member>   <member><name>postid</name><value><string>69</string></value></member>   <member><name>description</name><value><string>Blogasturias.com es el mayor directorio de blogs asturianos. En esta página se muestran los últimos artículos escritos en los blogs destacados del directorio y un listado de blogs por categorías.</string></value></member>   <member><name>title</name><value><string>Blogasturias.com</string></value></member>   <member><name>link</name><value><string>http://renefernandez.com/2010/12/blogasturias-com/</string></value></member>   <member><name>permaLink</name><value><string>http://renefernandez.com/2010/12/blogasturias-com/</string></value></member>   <member><name>categories</name><value><array><data>   <value><string>Páginas Web</string></value>   <value><string>Work</string></value> </data></array></value></member>   <member><name>mt_excerpt</name><value><string></string></value></member>   <member><name>mt_text_more</name><value><string></string></value></member>   <member><name>mt_allow_comments</name><value><int>1</int></value></member>   <member><name>mt_allow_pings</name><value><int>1</int></value></member>   <member><name>mt_keywords</name><value><string></string></value></member>   <member><name>wp_slug</name><value><string>blogasturias-com</string></value></member>   <member><name>wp_password</name><value><string></string></value></member>   <member><name>wp_author_id</name><value><string>1</string></value></member>   <member><name>wp_author_display_name</name><value><string>René</string></value></member>   <member><name>date_created_gmt</name><value><dateTime.iso8601>20101213T09:48:26</dateTime.iso8601></value></member>   <member><name>post_status</name><value><string>publish</string></value></member>   <member><name>custom_fields</name><value><array><data>   <value><struct>   <member><name>id</name><value><string>111</string></value></member>   <member><name>key</name><value><string>cliente</string></value></member>   <member><name>value</name><value><string>Blogasturias.com</string></value></member> </struct></value>   <value><struct>   <member><name>id</name><value><string>113</string></value></member>   <member><name>key</name><value><string>compania</string></value></member>   <member><name>value</name><value><string>El Comercio Digital</string></value></member> </struct></value>   <value><struct>   <member><name>id</name><value><string>116</string></value></member>   <member><name>key</name><value><string>imagen</string></value></member>   <member><name>value</name><value><string>http://renefernandez.com/wp-content/uploads/2010/12/blogasturias.jpg</string></value></member> </struct></value>   <value><struct>   <member><name>id</name><value><string>117</string></value></member>   <member><name>key</name><value><string>link</string></value></member>   <member><name>value</name><value><string>http://www.blogasturias.com</string></value></member> </struct></value>   <value><struct>   <member><name>id</name><value><string>112</string></value></member>   <member><name>key</name><value><string>tecnologia</string></value></member>   <member><name>value</name><value><string>PHP + HTML + CSS + MySQL + Javascript</string></value></member> </struct></value>   <value><struct>   <member><name>id</name><value><string>109</string></value></member>   <member><name>key</name><value><string>_edit_last</string></value></member>   <member><name>value</name><value><string>1</string></value></member> </struct></value>   <value><struct>   <member><name>id</name><value><string>110</string></value></member>   <member><name>key</name><value><string>_edit_lock</string></value></member>   <member><name>value</name><value><string>1292233707</string></value></member> </struct></value> </data></array></value></member>   <member><name>wp_post_format</name><value><string>standard</string></value></member> </struct></value>   <value><struct>   <member><name>dateCreated</name><value><dateTime.iso8601>20100211T00:28:23</dateTime.iso8601></value></member>   <member><name>userid</name><value><string>1</string></value></member>   <member><name>postid</name><value><string>66</string></value></member>   <member><name>description</name><value><string>Wickr (Wordpress Illegal Content Reporter) es un plugin de Wordpress desarrollado para combatir la pornografía infantil en la medida de lo posible desde el punto de vista de los bloggers que dispongan de un blog en un servidor propio.</string></value></member>   <member><name>title</name><value><string>Wickr</string></value></member>   <member><name>link</name><value><string>http://renefernandez.com/2010/02/wickr/</string></value></member>   <member><name>permaLink</name><value><string>http://renefernandez.com/2010/02/wickr/</string></value></member>   <member><name>categories</name><value><array><data>   <value><string>Plugins Wordpress</string></value> </data></array></value></member>   <member><name>mt_excerpt</name><value><string></string></value></member>   <member><name>mt_text_more</name><value><string></string></value></member>   <member><name>mt_allow_comments</name><value><int>1</int></value></member>   <member><name>mt_allow_pings</name><value><int>1</int></value></member>   <member><name>mt_keywords</name><value><string>PHP, WORDPRESS</string></value></member>   <member><name>wp_slug</name><value><string>wickr</string></value></member>   <member><name>wp_password</name><value><string></string></value></member>   <member><name>wp_author_id</name><value><string>1</string></value></member>   <member><name>wp_author_display_name</name><value><string>René</string></value></member>   <member><name>date_created_gmt</name><value><dateTime.iso8601>20100211T00:28:23</dateTime.iso8601></value></member>   <member><name>post_status</name><value><string>publish</string></value></member>   <member><name>custom_fields</name><value><array><data>   <value><struct>   <member><name>id</name><value><string>104</string></value></member>   <member><name>key</name><value><string>cliente</string></value></member>   <member><name>value</name><value><string>Comunidad de Wordpress</string></value></member> </struct></value>   <value><struct>   <member><name>id</name><value><string>105</string></value></member>   <member><name>key</name><value><string>compania</string></value></member>   <member><name>value</name><value><string>Proyecto Personal</string></value></member> </struct></value>   <value><struct>   <member><name>id</name><value><string>103</string></value></member>   <member><name>key</name><value><string>imagen</string></value></member>   <member><name>value</name><value><string>http://renefernandez.com/wp-content/uploads/2010/02/wickr-plugin.jpg</string></value></member> </struct></value>   <value><struct>   <member><name>id</name><value><string>106</string></value></member>   <member><name>key</name><value><string>link</string></value></member>   <member><name>value</name><value><string>http://bocabit.com/wickr-pornografia-infantil-wordpress</string></value></member> </struct></value>   <value><struct>   <member><name>id</name><value><string>107</string></value></member>   <member><name>key</name><value><string>tecnologia</string></value></member>   <member><name>value</name><value><string>PHP + WORDPRESS</string></value></member> </struct></value>   <value><struct>   <member><name>id</name><value><string>100</string></value></member>   <member><name>key</name><value><string>_edit_last</string></value></member>   <member><name>value</name><value><string>1</string></value></member> </struct></value>   <value><struct>   <member><name>id</name><value><string>99</string></value></member>   <member><name>key</name><value><string>_edit_lock</string></value></member>   <member><name>value</name><value><string>1265848105</string></value></member> </struct></value> </data></array></value></member>   <member><name>wp_post_format</name><value><string>standard</string></value></member> </struct></value>   <value><struct>   <member><name>dateCreated</name><value><dateTime.iso8601>20100209T08:21:54</dateTime.iso8601></value></member>   <member><name>userid</name><value><string>1</string></value></member>   <member><name>postid</name><value><string>55</string></value></member>   <member><name>description</name><value><string>Plugin de Wordpress que muestra 3 artículos destacados de manera aleatoria. Este plugin busca conseguir un equilibrio entre la simplicidad y la funcionalidad para conseguir el menor consumo de recursos posible. </string></value></member>   <member><name>title</name><value><string>Featured Random Posts</string></value></member>   <member><name>link</name><value><string>http://renefernandez.com/2010/02/featured-random-posts/</string></value></member>   <member><name>permaLink</name><value><string>http://renefernandez.com/2010/02/featured-random-posts/</string></value></member>   <member><name>categories</name><value><array><data>   <value><string>Plugins Wordpress</string></value> </data></array></value></member>   <member><name>mt_excerpt</name><value><string></string></value></member>   <member><name>mt_text_more</name><value><string></string></value></member>   <member><name>mt_allow_comments</name><value><int>1</int></value></member>   <member><name>mt_allow_pings</name><value><int>1</int></value></member>   <member><name>mt_keywords</name><value><string>PHP, WORDPRESS, XHTML</string></value></member>   <member><name>wp_slug</name><value><string>featured-random-posts</string></value></member>   <member><name>wp_password</name><value><string></string></value></member>   <member><name>wp_author_id</name><value><string>1</string></value></member>   <member><name>wp_author_display_name</name><value><string>René</string></value></member>   <member><name>date_created_gmt</name><value><dateTime.iso8601>20100209T08:21:54</dateTime.iso8601></value></member>   <member><name>post_status</name><value><string>publish</string></value></member>   <member><name>custom_fields</name><value><array><data>   <value><struct>   <member><name>id</name><value><string>81</string></value></member>   <member><name>key</name><value><string>cliente</string></value></member>   <member><name>value</name><value><string>Comunidad de Wordpress</string></value></member> </struct></value>   <value><struct>   <member><name>id</name><value><string>82</string></value></member>   <member><name>key</name><value><string>compania</string></value></member>   <member><name>value</name><value><string>Proyecto Personal</string></value></member> </struct></value>   <value><struct>   <member><name>id</name><value><string>86</string></value></member>   <member><name>key</name><value><string>imagen</string></value></member>   <member><name>value</name><value><string>http://renefernandez.com/wp-content/uploads/2010/02/wordpress-frp.jpg</string></value></member> </struct></value>   <value><struct>   <member><name>id</name><value><string>89</string></value></member>   <member><name>key</name><value><string>link</string></value></member>   <member><name>value</name><value><string>http://bocabit.com/featured-random-posts</string></value></member> </struct></value>   <value><struct>   <member><name>id</name><value><string>87</string></value></member>   <member><name>key</name><value><string>tecnologia</string></value></member>   <member><name>value</name><value><string>PHP + XHTML</string></value></member> </struct></value>   <value><struct>   <member><name>id</name><value><string>80</string></value></member>   <member><name>key</name><value><string>_edit_last</string></value></member>   <member><name>value</name><value><string>1</string></value></member> </struct></value>   <value><struct>   <member><name>id</name><value><string>79</string></value></member>   <member><name>key</name><value><string>_edit_lock</string></value></member>   <member><name>value</name><value><string>1265704891</string></value></member> </struct></value> </data></array></value></member>   <member><name>wp_post_format</name><value><string>standard</string></value></member> </struct></value>   <value><struct>   <member><name>dateCreated</name><value><dateTime.iso8601>20091104T19:00:16</dateTime.iso8601></value></member>   <member><name>userid</name><value><string>1</string></value></member>   <member><name>postid</name><value><string>14</string></value></member>   <member><name>description</name><value><string>Maquetación a partir de un diseño proporcionado en imágenes de toda la site utilizando como tecnologías PHP, Wordpress, CSS y Javascript de terceros.</string></value></member>   <member><name>title</name><value><string>Dieta Fitness</string></value></member>   <member><name>link</name><value><string>http://renefernandez.com/2009/11/dieta-fitness/</string></value></member>   <member><name>permaLink</name><value><string>http://renefernandez.com/2009/11/dieta-fitness/</string></value></member>   <member><name>categories</name><value><array><data>   <value><string>Páginas Web</string></value> </data></array></value></member>   <member><name>mt_excerpt</name><value><string></string></value></member>   <member><name>mt_text_more</name><value><string></string></value></member>   <member><name>mt_allow_comments</name><value><int>1</int></value></member>   <member><name>mt_allow_pings</name><value><int>1</int></value></member>   <member><name>mt_keywords</name><value><string>CSS, JS, PHP, WORDPRESS, XHTML</string></value></member>   <member><name>wp_slug</name><value><string>dieta-fitness</string></value></member>   <member><name>wp_password</name><value><string></string></value></member>   <member><name>wp_author_id</name><value><string>1</string></value></member>   <member><name>wp_author_display_name</name><value><string>René</string></value></member>   <member><name>date_created_gmt</name><value><dateTime.iso8601>20091104T19:00:16</dateTime.iso8601></value></member>   <member><name>post_status</name><value><string>publish</string></value></member>   <member><name>custom_fields</name><value><array><data>   <value><struct>   <member><name>id</name><value><string>36</string></value></member>   <member><name>key</name><value><string>cliente</string></value></member>   <member><name>value</name><value><string>Dieta Fitness</string></value></member> </struct></value>   <value><struct>   <member><name>id</name><value><string>37</string></value></member>   <member><name>key</name><value><string>compania</string></value></member>   <member><name>value</name><value><string>Blogs SAI (Red de Blogs)</string></value></member> </struct></value>   <value><struct>   <member><name>id</name><value><string>41</string></value></member>   <member><name>key</name><value><string>imagen</string></value></member>   <member><name>value</name><value><string>http://renefernandez.com/wp-content/uploads/2009/11/dieta-fitness-captura.jpg</string></value></member> </struct></value>   <value><struct>   <member><name>id</name><value><string>39</string></value></member>   <member><name>key</name><value><string>link</string></value></member>   <member><name>value</name><value><string>http://dietafitness.com</string></value></member> </struct></value>   <value><struct>   <member><name>id</name><value><string>49</string></value></member>   <member><name>key</name><value><string>tecnologia</string></value></member>   <member><name>value</name><value><string>CSS + PHP + Wordpress + JS</string></value></member> </struct></value>   <value><struct>   <member><name>id</name><value><string>31</string></value></member>   <member><name>key</name><value><string>_edit_last</string></value></member>   <member><name>value</name><value><string>1</string></value></member> </struct></value>   <value><struct>   <member><name>id</name><value><string>30</string></value></member>   <member><name>key</name><value><string>_edit_lock</string></value></member>   <member><name>value</name><value><string>1265704682</string></value></member> </struct></value> </data></array></value></member>   <member><name>wp_post_format</name><value><string>standard</string></value></member> </struct></value>   <value><struct>   <member><name>dateCreated</name><value><dateTime.iso8601>20091104T18:13:32</dateTime.iso8601></value></member>   <member><name>userid</name><value><string>1</string></value></member>   <member><name>postid</name><value><string>4</string></value></member>   <member><name>description</name><value><string>&lt;a href=&quot;http://bocabit.com&quot; title=&quot;bocabit.com&quot;&gt;bocabit.com&lt;/a&gt; es mi primer y más duradero proyecto. Se trata de lo que comenzó siendo mi blog personal, pero con el paso del tiempo se ha convertido en una página web con varios redactores que aportan sus propios puntos de vista sobre la actualidad, la tecnología y numerosas curiosidades. El blog funciona gracias a Wordpress y &lt;strong&gt;tanto diseño, como maquetación y programación&lt;/strong&gt; son míos.</string></value></member>   <member><name>title</name><value><string>bocabit.com</string></value></member>   <member><name>link</name><value><string>http://renefernandez.com/2009/11/bocabit-com/</string></value></member>   <member><name>permaLink</name><value><string>http://renefernandez.com/2009/11/bocabit-com/</string></value></member>   <member><name>categories</name><value><array><data>   <value><string>Páginas Web</string></value> </data></array></value></member>   <member><name>mt_excerpt</name><value><string></string></value></member>   <member><name>mt_text_more</name><value><string></string></value></member>   <member><name>mt_allow_comments</name><value><int>1</int></value></member>   <member><name>mt_allow_pings</name><value><int>1</int></value></member>   <member><name>mt_keywords</name><value><string>CSS, JS, PHP, PSD, SEO, XHTML</string></value></member>   <member><name>wp_slug</name><value><string>bocabit-com</string></value></member>   <member><name>wp_password</name><value><string></string></value></member>   <member><name>wp_author_id</name><value><string>1</string></value></member>   <member><name>wp_author_display_name</name><value><string>René</string></value></member>   <member><name>date_created_gmt</name><value><dateTime.iso8601>20091104T18:13:32</dateTime.iso8601></value></member>   <member><name>post_status</name><value><string>publish</string></value></member>   <member><name>custom_fields</name><value><array><data>   <value><struct>   <member><name>id</name><value><string>5</string></value></member>   <member><name>key</name><value><string>cliente</string></value></member>   <member><name>value</name><value><string>Blog Público</string></value></member> </struct></value>   <value><struct>   <member><name>id</name><value><string>27</string></value></member>   <member><name>key</name><value><string>compania</string></value></member>   <member><name>value</name><value><string>Proyecto Personal</string></value></member> </struct></value>   <value><struct>   <member><name>id</name><value><string>10</string></value></member>   <member><name>key</name><value><string>imagen</string></value></member>   <member><name>value</name><value><string>http://renefernandez.com/wp-content/uploads/2009/11/bocabit-captura.png</string></value></member> </struct></value>   <value><struct>   <member><name>id</name><value><string>8</string></value></member>   <member><name>key</name><value><string>link</string></value></member>   <member><name>value</name><value><string>http://bocabit.com</string></value></member> </struct></value>   <value><struct>   <member><name>id</name><value><string>47</string></value></member>   <member><name>key</name><value><string>tecnologia</string></value></member>   <member><name>value</name><value><string>PHP + CSS + XHMTL + JS + PSD + SEO</string></value></member> </struct></value>   <value><struct>   <member><name>id</name><value><string>4</string></value></member>   <member><name>key</name><value><string>_edit_last</string></value></member>   <member><name>value</name><value><string>1</string></value></member> </struct></value>   <value><struct>   <member><name>id</name><value><string>3</string></value></member>   <member><name>key</name><value><string>_edit_lock</string></value></member>   <member><name>value</name><value><string>1265715762</string></value></member> </struct></value> </data></array></value></member>   <member><name>wp_post_format</name><value><string>standard</string></value></member> </struct></value> </data></array>       </value>     </param>   </params> </methodResponse>";
	
    NSLog(@"%s", (char*)_cmd);
	NSLog(@"----------------");
	
	NSData *d = [s dataUsingEncoding:NSUTF8StringEncoding];
	
	p = [[XMLRPCDecoder alloc] initWithData:d];
	
	id u = [p decode];
	
	NSLog(@"El objeto recibido es: %@", [u class]);
	
	NSArray *a = u;
	
	STAssertTrue([a isKindOfClass:[NSArray class]], @"El objeto \"a\" debería ser un NSArray");
	STAssertNotNil(a, @"El objeto devuelto no debería ser Nil");
	
	u= [a objectAtIndex:0];
	
	STAssertNotNil(u, @"El objeto devuelto no debería ser Nil");
	
	value = [u objectForKey:@"description"];
	
	STAssertTrue([value isEqualToString:@"Guía médica del Principado de Asturias."],@"Debería ser 'Guía médica del Principado de Asturias.'(%@)", [di objectForKey:@"description"]);
	
	//NSArray *cats= nil;
	value = [u objectForKey:@"dateCreated"];
	
	STAssertTrue([value isKindOfClass:[NSDate class]], @"El objeto \"a\" debería ser un NSDate");
	
	NSCalendar *cal = [[NSCalendar alloc]
					   initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSDateComponents *dateComponents = [cal components:(NSDayCalendarUnit | NSWeekdayCalendarUnit | NSYearCalendarUnit) fromDate:value];
	
	NSInteger year = [dateComponents year];
	
	//STAssertNotNil(year, @"El objeto devuelto no debería ser Nil");
	
	STAssertTrue(year==2011,@"Debería ser '2011'(%@)", year);
	
	value = [u objectForKey:@"categories"];
	
	STAssertTrue([value isKindOfClass:[NSArray class]], @"El objeto \"a\" debería ser un NSArray");
	
	STAssertTrue([[value objectAtIndex:0] isEqualToString:@"Páginas Web"],@"Debería ser 'Páginas Web'(%@)", [value objectAtIndex:0]);
	
}

- (void)testParseOption{
	
	NSString *s=@"<?xml version=\"1.0\"?> <methodResponse>   <params>     <param>       <value>       <struct>   <member><name>software_name</name><value><struct>   <member><name>desc</name><value><string>Nombre de la aplicación</string></value></member>   <member><name>readonly</name><value><boolean>1</boolean></value></member>   <member><name>value</name><value><string>WordPress</string></value></member> </struct></value></member> </struct>       </value>     </param>   </params> </methodResponse>";
	
    NSLog(@"%s", (char*)_cmd);
	NSLog(@"----------------");
	
	NSData *d = [s dataUsingEncoding:NSUTF8StringEncoding];
	
	p = [[XMLRPCDecoder alloc] initWithData:d];
	
	id u = [p decode];
	
	NSLog(@"El objeto recibido es: %@", [u class]);
	
	NSDictionary *a = u;
	
	STAssertTrue([a isKindOfClass:[NSDictionary class]], @"El objeto \"a\" debería ser un NSDictionary");
	STAssertNotNil(a, @"El objeto devuelto no debería ser Nil");
	
	value= [a objectForKey:@"software_name"];
	
	STAssertNotNil(value, @"El objeto devuelto no debería ser Nil");
	
	value = [value objectForKey:@"desc"];
	
	STAssertTrue([value isEqualToString:@"Nombre de la aplicación"],@"Debería ser Nombre de la aplicación(%@)", [di objectForKey:@"desc"]);
	
}

- (void)testParseUsersBlogs{
	
	NSString *s=@"<?xml version=\"1.0\"?><methodResponse>	<params>    <param>	<value>	<array><data><value><struct>	<member><name>isAdmin</name><value><boolean>1</boolean></value></member>	<member><name>url</name><value><string>http://renefernandez.com/</string></value></member>	<member><name>blogid</name><value><string>1</string></value></member>	<member><name>blogName</name><value><string>René Fernández Sánchez</string></value></member>	<member><name>xmlrpc</name><value><string>http://renefernandez.com/xmlrpc.php</string></value></member>	</struct></value>	</data></array>	</value>    </param>	</params>	</methodResponse>";
	
    NSLog(@"%s", (char*)_cmd);
	NSLog(@"----------------");
	
	NSData *d = [s dataUsingEncoding:NSUTF8StringEncoding];
	
	p = [[XMLRPCDecoder alloc] initWithData:d];
	
	id u = [p decode];
	
	NSLog(@"El objeto recibido es: %@", [u class]);
	
	STAssertTrue([u isKindOfClass:[NSArray class]], @"El objeto \"a\" no es un array");
	
	NSArray *a = u;
	//NSDictionary *a=  [[NSDictionary alloc] init];
	//NSLog(@"%@",[a description]);
	
	STAssertTrue([a isKindOfClass:[NSArray class]], @"El objeto \"a\" no es un array");
	
	STAssertTrue([a count] == 1, @"El array debería tener un elemento(%d)", [a count]);
	
	NSLog(@"%@",[[a objectAtIndex:0] description]);
	
	NSLog(@"El objeto dentro de \"a\" es: %@", [[a objectAtIndex:0] class]);
	
	STAssertTrue([[a objectAtIndex:0] isKindOfClass:[NSDictionary class]], @"El objeto devuelto no es un diccionario");
	
	di=[a objectAtIndex:0];
	
	value=nil;
	
	value=(NSNumber *)[di objectForKey:@"isAdmin"];
	
	STAssertTrue([value intValue]==1,@"Debería ser 1(%@)", [di objectForKey:@"isAdmin"]);
	
	NSLog(@"value=: %@", [value class]);	
	
	value= (NSString*)[di objectForKey:@"blogName"];
	
	NSLog(@"value=: %@", [value class]);
	
	for (NSString* key in di) {
		//id value = [di objectForKey:key];
		NSLog(@"\tkey: %@   value:%@", key, [di objectForKey:key]);
		// do stuff
	}
	
	STAssertTrue([value isEqualToString:@"René Fernández Sánchez"],@"Debería ser René Fernández Sánchez(%@)", [di objectForKey:@"blogName"]);
	
}

- (void)testParseTags{
	
	NSString *s=@"<?xml version=\"1.0\"?> <methodResponse>   <params>     <param>       <value>       <array><data>   <value><struct>   <member><name>tag_id</name><value><string>16</string></value></member>   <member><name>name</name><value><string>CSS</string></value></member>   <member><name>count</name><value><string>2</string></value></member>   <member><name>slug</name><value><string>css</string></value></member>   <member><name>html_url</name><value><string>http://renefernandez.com/tag/css/</string></value></member>   <member><name>rss_url</name><value><string>http://renefernandez.com/tag/css/feed/</string></value></member> </struct></value>   <value><struct>   <member><name>tag_id</name><value><string>13</string></value></member>   <member><name>name</name><value><string>JS</string></value></member>   <member><name>count</name><value><string>2</string></value></member>   <member><name>slug</name><value><string>js</string></value></member>   <member><name>html_url</name><value><string>http://renefernandez.com/tag/js/</string></value></member>   <member><name>rss_url</name><value><string>http://renefernandez.com/tag/js/feed/</string></value></member> </struct></value>   <value><struct>   <member><name>tag_id</name><value><string>17</string></value></member>   <member><name>name</name><value><string>PHP</string></value></member>   <member><name>count</name><value><string>4</string></value></member>   <member><name>slug</name><value><string>php</string></value></member>   <member><name>html_url</name><value><string>http://renefernandez.com/tag/php/</string></value></member>   <member><name>rss_url</name><value><string>http://renefernandez.com/tag/php/feed/</string></value></member> </struct></value>   <value><struct>   <member><name>tag_id</name><value><string>14</string></value></member>   <member><name>name</name><value><string>PSD</string></value></member>   <member><name>count</name><value><string>1</string></value></member>   <member><name>slug</name><value><string>psd</string></value></member>   <member><name>html_url</name><value><string>http://renefernandez.com/tag/psd/</string></value></member>   <member><name>rss_url</name><value><string>http://renefernandez.com/tag/psd/feed/</string></value></member> </struct></value>   <value><struct>   <member><name>tag_id</name><value><string>15</string></value></member>   <member><name>name</name><value><string>SEO</string></value></member>   <member><name>count</name><value><string>1</string></value></member>   <member><name>slug</name><value><string>seo</string></value></member>   <member><name>html_url</name><value><string>http://renefernandez.com/tag/seo/</string></value></member>   <member><name>rss_url</name><value><string>http://renefernandez.com/tag/seo/feed/</string></value></member> </struct></value>   <value><struct>   <member><name>tag_id</name><value><string>18</string></value></member>   <member><name>name</name><value><string>WORDPRESS</string></value></member>   <member><name>count</name><value><string>3</string></value></member>   <member><name>slug</name><value><string>wordpress</string></value></member>   <member><name>html_url</name><value><string>http://renefernandez.com/tag/wordpress/</string></value></member>   <member><name>rss_url</name><value><string>http://renefernandez.com/tag/wordpress/feed/</string></value></member> </struct></value>   <value><struct>   <member><name>tag_id</name><value><string>19</string></value></member>   <member><name>name</name><value><string>XHTML</string></value></member>   <member><name>count</name><value><string>3</string></value></member>   <member><name>slug</name><value><string>xhtml</string></value></member>   <member><name>html_url</name><value><string>http://renefernandez.com/tag/xhtml/</string></value></member>   <member><name>rss_url</name><value><string>http://renefernandez.com/tag/xhtml/feed/</string></value></member> </struct></value> </data></array>       </value>     </param>   </params> </methodResponse>";
	
    NSLog(@"%s", (char*)_cmd);
	NSLog(@"----------------");
	
	NSData *d = [s dataUsingEncoding:NSUTF8StringEncoding];
	
	p = [[XMLRPCDecoder alloc] initWithData:d];
	
	id u = [p decode];
	
	NSLog(@"El objeto recibido es: %@", [u class]);
	
	STAssertTrue([u isKindOfClass:[NSArray class]], @"El objeto \"a\" no es un array");
	
	NSArray *a = u;
	//NSDictionary *a=  [[NSDictionary alloc] init];
	//NSLog(@"%@",[a description]);
	
	STAssertTrue([a isKindOfClass:[NSArray class]], @"El objeto \"a\" no es un array");
	
	STAssertTrue([a count] == 7, @"El array debería tener un elemento(%d)", [a count]);
	
	NSLog(@"%@",[[a objectAtIndex:0] description]);
	
	NSLog(@"El objeto dentro de \"a\" es: %@", [[a objectAtIndex:0] class]);
	
	STAssertTrue([[a objectAtIndex:0] isKindOfClass:[NSDictionary class]], @"El objeto devuelto no es un diccionario");
	
	
	// Elemento 0
	di=[a objectAtIndex:0];
	
	value=nil;
	
	value=(NSNumber *)[di objectForKey:@"count"];
	
	STAssertTrue([value intValue]==2,@"Debería ser 2(%@)", [di objectForKey:@"isAdmin"]);
	
	NSLog(@"value=: %@", [value class]);	
	
	value= (NSString*)[di objectForKey:@"name"];
	
	NSLog(@"value=: %@", [value class]);
	
	for (NSString* key in di) {
		//id value = [di objectForKey:key];
		NSLog(@"\tkey: %@   value:%@", key, [di objectForKey:key]);
		// do stuff
	}
	
	STAssertTrue([value isEqualToString:@"CSS"],@"Debería ser CSS(%@)", [di objectForKey:@"name"]);
	
	// Elemento 7
	di=[a objectAtIndex:6];
	
	for (NSString* key in di) {
		//id value = [di objectForKey:key];
		NSLog(@"\tkey: %@   value:%@", key, [di objectForKey:key]);
		// do stuff
	}
	
	value=nil;
	
	value=(NSNumber *)[di objectForKey:@"count"];
	
	STAssertTrue([value intValue]==3,@"Debería ser 3(%@)", [di objectForKey:@"isAdmin"]);
	
	NSLog(@"value=: %@", [value class]);	
	
	value= (NSString*)[di objectForKey:@"name"];
	
	NSLog(@"value=: %@", [value class]);
	
	for (NSString* key in di) {
		//id value = [di objectForKey:key];
		NSLog(@"\tkey: %@   value:%@", key, [di objectForKey:key]);
		// do stuff
	}
	
	STAssertTrue([value isEqualToString:@"XHTML"],@"Debería ser XHTML(%@)", [di objectForKey:@"name"]);
	
	// Elemento 8
	//di=[a objectAtIndex:8];
	
	STAssertThrows([a objectAtIndex:7], @"El Array solo tiene 7 elementos (0-6)");
	
	//Elemento -1
	STAssertThrows([a objectAtIndex:-1], @"El Array solo tiene 7 elementos (0-6)");
	
	
}

- (void)testParserEmptyXml{
	
	NSString *s=@"";
	
    NSLog(@"%s", (char*)_cmd);
	NSLog(@"----------------");
	
	NSData *d = [s dataUsingEncoding:NSUTF8StringEncoding];
	
	p = [[XMLRPCDecoder alloc] initWithData:d];
	
	id u = [p decode];
	
	NSLog(@"El objeto recibido es: %@", [u class]);
	
	NSArray *a = u;
	
	
	STAssertFalse([a isKindOfClass:[NSArray class]], @"El objeto \"a\" no es un array");
	STAssertNil(a, @"El objeto devuelto debería ser Nil");
	
}


@end
