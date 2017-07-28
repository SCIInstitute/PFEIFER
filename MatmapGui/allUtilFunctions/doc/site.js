/*
A wee bit of java script that supports the construction of CVRTI
web pages. 

tjd
*/

/* 
Try to determine relative location of page with respect to the
top of the site tree.  If this can't be done, i.e. if page is not in
the site tree then return top of site tree as the url of the CVRTI
web site.  
*/

function findSiteTop() {
  var path = location.pathname.substr(0, location.pathname.lastIndexOf("/"));
  var rootDir = "htdocs";
  var siteTop="";
  var base = path.substr(path.lastIndexOf("/") + 1);
  while (base != rootDir && base != "") {
    siteTop += "../";
    path = path.substr(0, path.lastIndexOf("/"));
    base = path.substr(path.lastIndexOf("/")+1);
  }
  if (base == "") {
    siteTop = "http://www.cvrti.utah.edu/";
  } 
  return siteTop;
}

/*
Return page's "category" value.  E.g., research, seminars, etc.
*/

function getPageCategory() {
  return document.getElementById("page_category").firstChild.nodeValue;  
}

/*
Insert boilerplate page graphics. 
*/
function doPageGraphic() {
  document.write("\
    <map name=\"span_top4acf91\" id=\"span_top4acf91\">\
      <area href=\"", siteTop, "index.html\" alt=\"CVRTI Home\" coords=\"56,262,135,294\"\
	shape=\"rect\" />\
    </map>\
    <img class=\"frame-top\" src=\"", siteTop, "images/tit_empty.gif\"\
      alt=\"Page top ecg on grid graphic\" height=\"79\"\
      width=\"407\" />\
    <div class=\"frame-left\">\
      <img class=\"block\" src=\"", siteTop, "images/span_top.gif\"\
        alt=\"Page left-top side heart image.\"\
	usemap=\"#span_top4acf91\" height=\"306\" width=\"173\"/>\
      <img class=\"block\" src=\"", siteTop, "images/span_bot.gif\"\
        alt=\"Page left-bottom side grid graphic.\"\
        height=\"65\" width=\"173\"/>\
    </div>\
  ");
}

function doNavLinks() {
  document.write("<div class=\"nav-links\">");
  doBareNavLinks();
  document.write("</div>");
}

function doBareNavLinks() {
  document.write("\
      <a class=\"nav-link\" href=\"", siteTop, "contact/contact.html\">Contact Info</a>\
      <a class=\"nav-link\" href=\"", siteTop, "positions/positions.html\">Open Positions</a>\
      <a class=\"nav-link\" href=\"", siteTop, "personnel/personnel.html\">Personnel</a>\
      <a class=\"nav-link\" href=\"", siteTop, "publications/pubs-index.html\">Publications</a>\
      <a class=\"nav-link\" href=\"", siteTop, "research/research.html\">Research</a>\
      <a class=\"nav-link\" href=\"", siteTop, "research/wo/wo.html\">&nbsp;&nbsp;Whole Organ</a>\
      <a class=\"nav-link\" href=\"", siteTop, "research/cell/cell.html\">&nbsp;&nbsp;Cellular/Molecular</a>\
      <a class=\"nav-link\" href=\"", siteTop, "resources/resources.html\">Resources</a>\
      <a class=\"nav-link\" href=\"", siteTop, "seminars/seminars.html\">Seminars </a>\
      <a class=\"nav-link\" href=\"", siteTop, "whatsnew/whatsnew.html\">What\'s New </a>\
      <a id=\"about-this-site\" class=\"nav-link\" href=\"", siteTop, "about/about.html\">About This Site</a>\
");
}

/*
Write shadowed page category string.
*/
function doPageCategory() {
  document.write("\
   <div class=\"page-category-text-shadow\">",
   getPageCategory(),
   "</div>\
   <div class=\"page-category-text\">",
   getPageCategory(),
   "</div>\
  ");
}

/*
Write raw page footer (no surrounding context).
*/
function doBareFooter() {
  document.write("\
    Nora Eccles Harrison Cardiovascular Research and Training\
    Institute<br />University of Utah | Salt Lake City, UT\
    84112 | (801) 581-8183<br />\
  <a href=\"http://www.utah.edu/disclaimer/disclaimer_home.html\">Disclaimer</a>\
  | <a href=\"", siteTop, "about/about.html\">About This Site</a>\
  ");
}

/*
Write page footer in the context of a "footer" div class.
*/
function doFooterLinks() {
  document.write("<div class=\"footer\">");
  doBareFooter();
  document.write("</div>");
}

/*
Start page content.
*/
function beginContent() {
  document.write("<div id=\"content\">");
}

/*
End page content.
*/
function endContent() {
  document.write("</div>");
}

/*
Write page pre-content stuff.
*/
function preContent() {
  doPageGraphic();
  doPageCategory();
  doNavLinks();
  beginContent();
}

/*
Write page post-content stuff.
*/
function postContent() {
  doFooterLinks();
  endContent();
}

/*
For every other div element of class divClass, change the div element's
class to divClass + "-odd".  Used, for instance, in alternately highlighting
the rows of table.
*/
function stripeDivElementsWithClass(divClass) {
  var nodeList = document.body.getElementsByTagName("div");
  var doOddEntry = false;
  for (var i=0; i < nodeList.length; ++i) {
    var element = nodeList.item(i);
      var attrNode = element.attributes.getNamedItem("class");
      if (attrNode != null && attrNode.nodeValue == divClass) {
        if (doOddEntry) {
	  attrNode.nodeValue = divClass + "-odd";
      	}
      doOddEntry = !doOddEntry;
    }
  }
}

/*
  Start of Toc object code
*/

/*
  The toc code should be used as follows:
  -Insert the following anchor element before the content to be toc'ed:
    <a id="begin-toc">tag-list</a>
   where 'tag-list' is list of tags with optional class attributes that are to be toc'ed.
   Tags themselves must be upper-case.  Class attributes may be upper or lower case.
  -Insert the following script element after all content to be toc'ed:
    <script  type="text/javascript">new Toc().build()</script>
  -Add css style rules that manifest hierarchical arrangements amongst entries in the toc.  
   Rules follow this form:  a.toc-tag-class where 'toc' must be literally present, 'tag' is a 
   tag name, and 'class' is an optional class attribute.  The '-' must be present.

  To do: All the toc entries ought to wrapped up in their own div.
*/

/* Constructor. */
function Toc() { }

/* Initialize toc variables */
Toc.prototype.initToc = function() {
  this.firstEntry = false;
  this.tocElement = document.createElement("H1");
  this.tocElement.setAttribute("id", "toc");
  text = document.createTextNode("Table of Contents");
  this.tocElement.appendChild(text);
  this.startElement.parentNode.insertBefore(this.tocElement, this.startElement.nextSibling);
  this.idCount = 0;
  this.tocLast = this.tocElement;
  this.tocPrefix = "toc";
}

/* Return a unique id number */
Toc.prototype.newIdNum = function() {
  this.idCount += 1;
  return this.idCount;
}

/* Return current id number */
Toc.prototype.idNum = function() {
  if (this.idCount == 0)
    this.idCount = 1;
  return this.idCount;
}

/* Return a new unique (?) string to be used as the id of a toc
   target. */
Toc.prototype.newIdString = function() {
  var id = this.tocPrefix + String(this.newIdNum());
  return id;
}

/* Return the current toc target id string in play */
Toc.prototype.idString = function() {
  return this.tocPrefix + String(this.idNum());
}

/* Add, as 'node's previous sibling, an anchor node to be used as a
   toc target */
Toc.prototype.addTarget = function(node) {
  var target = document.createElement("A");
  var idString = this.newIdString();
  target.setAttribute("id", idString);
  node.parentNode.insertBefore(target, node);
}

/* Add a toc entry which references its target */
Toc.prototype.addSource = function(node, cl) {
  var p = document.createElement("P");
  p.setAttribute("class", cl);
  var source = document.createElement("A");
  source.setAttribute("href", "#"+this.idString());
  var text = this.getText(node);
  source.appendChild(text)
  p.appendChild(source);
  this.tocLast.parentNode.insertBefore(p, this.tocLast.nextSibling);
  this.tocLast = p;
}

/* Concat all of a node's text children into one text node while
   converting <br> elements into spaces */
Toc.prototype.getText = function(node) {
  var textNode = document.createTextNode("");
  var aNode = node.firstChild;
  while (aNode != null) {
    switch (aNode.nodeType) {
    case 1:
      if (aNode.tagName == "BR")
        textNode.appendData(" ");
      break;
    case 3:
      textNode.appendData(aNode.data);
      break;
    }
    aNode = aNode.nextSibling;
  }
  return textNode;
}

/* Initialize the toc if necessary and then add 'node' to the toc.
   'cl' is a string suffix that will be part of the node's class
   attribute. */
Toc.prototype.addEntry = function(node, cl) {
  if (this.firstEntry == true) {
    this.initToc();
  }
  this.addTarget(node);
  this.addSource(node, cl);
}

/* Build a toc */
Toc.prototype.build = function() {

  /* Abort if <a class="begin-toc"> is missing or has empty content */
  this.startElement = document.getElementById("begin-toc");
  if (this.startElement == null || this.startElement.firstChild == null)
    return;
  else {
    /* Mark end of toc */
    document.write("<a id=\"end-toc\"></a>")
    this.endElement = document.getElementById("end-toc");

    /* Build array of toc-able elements from content of <a class="begin-toc"> */
    this.firstEntry = true;
    this.tocElement = null;
    var tocablesString = this.startElement.firstChild.nodeValue;
    var ta = tocablesString.split(/ +/);
    this.tocablesArray = new Array();
    for (var i=0; i<ta.length; ++i) {
      var t = ta[i].split(".");
      this.tocablesArray[i] = { tag : t[0], clas : null };
      if (t.length == 2)
        this.tocablesArray[i].clas = t[1];
    }

    /* Build the toc */
    var nextElement = this.startElement.nextSibling;
    while (true) {
      if (nextElement == this.endElement)
        return null;
      for (var i=0; i<this.tocablesArray.length; ++i) {
        if (nextElement.nodeType == 1) {
          classAttrNode = nextElement.attributes.getNamedItem("class");
          var classAttr = classAttrNode == null ? null : classAttrNode.nodeValue;
          if (nextElement.nodeName == this.tocablesArray[i].tag && classAttr == this.tocablesArray[i].clas) {
            var className = "toc-" + nextElement.nodeName;
	   if (classAttr != null)
	     className = className + "-" + classAttr;
	   this.addEntry(nextElement, className);
	   break;
	  }
	}
      }
      nextElement = nextElement.nextSibling;
    }
  }
}

function pStr(str) {
  document.write("<p>", str, "</p>");
}

function pNode(str, node) {
  pStr(str + node.NodeName);
}

var siteTop = findSiteTop();
