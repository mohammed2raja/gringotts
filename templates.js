define(['handlebars'], function(Handlebars) {

this["Handlebars"] = this["Handlebars"] || {};

Handlebars.registerPartial("pagination", Handlebars.template({"1":function(container,depth0,helpers,partials,data) {
    var stack1;

  return ((stack1 = helpers["if"].call(depth0 != null ? depth0 : {},(depth0 != null ? depth0.routeName : depth0),{"name":"if","hash":{},"fn":container.program(2, data, 0),"inverse":container.noop,"data":data})) != null ? stack1 : "");
},"2":function(container,depth0,helpers,partials,data) {
    var stack1, helper, alias1=depth0 != null ? depth0 : {}, alias2=helpers.helperMissing, alias3=container.escapeExpression, alias4="function";

  return "\n    <a href=\""
    + alias3((helpers.url || (depth0 && depth0.url) || alias2).call(alias1,(depth0 != null ? depth0.routeName : depth0),(depth0 != null ? depth0.routeParams : depth0),(depth0 != null ? depth0.prevState : depth0),{"name":"url","hash":{},"data":data}))
    + "\"\n       class=\"prev-page "
    + ((stack1 = helpers.unless.call(alias1,(depth0 != null ? depth0.multiPaged : depth0),{"name":"unless","hash":{},"fn":container.program(3, data, 0),"inverse":container.program(5, data, 0),"data":data})) != null ? stack1 : "")
    + "\">\n      "
    + alias3((helpers.icon || (depth0 && depth0.icon) || alias2).call(alias1,"thin-arrow","rotate-left",{"name":"icon","hash":{},"data":data}))
    + "\n    </a>\n    <strong>"
    + alias3(((helper = (helper = helpers.range || (depth0 != null ? depth0.range : depth0)) != null ? helper : alias2),(typeof helper === alias4 ? helper.call(alias1,{"name":"range","hash":{},"data":data}) : helper)))
    + " of "
    + alias3(((helper = (helper = helpers.count || (depth0 != null ? depth0.count : depth0)) != null ? helper : alias2),(typeof helper === alias4 ? helper.call(alias1,{"name":"count","hash":{},"data":data}) : helper)))
    + "</strong>\n    <a href=\""
    + alias3((helpers.url || (depth0 && depth0.url) || alias2).call(alias1,(depth0 != null ? depth0.routeName : depth0),(depth0 != null ? depth0.routeParams : depth0),(depth0 != null ? depth0.nextState : depth0),{"name":"url","hash":{},"data":data}))
    + "\"\n       class=\"next-page "
    + ((stack1 = helpers.unless.call(alias1,(depth0 != null ? depth0.multiPaged : depth0),{"name":"unless","hash":{},"fn":container.program(3, data, 0),"inverse":container.program(8, data, 0),"data":data})) != null ? stack1 : "")
    + "\">\n      "
    + alias3((helpers.icon || (depth0 && depth0.icon) || alias2).call(alias1,"thin-arrow","rotate-right",{"name":"icon","hash":{},"data":data}))
    + "\n    </a>\n  ";
},"3":function(container,depth0,helpers,partials,data) {
    return "hidden";
},"5":function(container,depth0,helpers,partials,data) {
    var stack1;

  return ((stack1 = helpers.unless.call(depth0 != null ? depth0 : {},(depth0 != null ? depth0.prev : depth0),{"name":"unless","hash":{},"fn":container.program(6, data, 0),"inverse":container.noop,"data":data})) != null ? stack1 : "");
},"6":function(container,depth0,helpers,partials,data) {
    return "disabled-arrow";
},"8":function(container,depth0,helpers,partials,data) {
    var stack1;

  return ((stack1 = helpers.unless.call(depth0 != null ? depth0 : {},(depth0 != null ? depth0.next : depth0),{"name":"unless","hash":{},"fn":container.program(6, data, 0),"inverse":container.noop,"data":data})) != null ? stack1 : "");
},"compiler":[7,">= 4.0.0"],"main":function(container,depth0,helpers,partials,data) {
    var stack1, helper, alias1=depth0 != null ? depth0 : {};

  return "<div class=\"pagination-controls "
    + container.escapeExpression(((helper = (helper = helpers.viewId || (depth0 != null ? depth0.viewId : depth0)) != null ? helper : helpers.helperMissing),(typeof helper === "function" ? helper.call(alias1,{"name":"viewId","hash":{},"data":data}) : helper)))
    + "\">\n  "
    + ((stack1 = helpers["if"].call(alias1,(depth0 != null ? depth0.count : depth0),{"name":"if","hash":{},"fn":container.program(1, data, 0),"inverse":container.noop,"data":data})) != null ? stack1 : "")
    + "\n</div>\n";
},"useData":true}));

Handlebars.registerPartial("sortTableHeader", Handlebars.template({"1":function(container,depth0,helpers,partials,data) {
    var stack1, helper, alias1=depth0 != null ? depth0 : {}, alias2=helpers.helperMissing, alias3="function", alias4=container.escapeExpression;

  return "  <th data-sort=\""
    + alias4(((helper = (helper = helpers.attr || (depth0 != null ? depth0.attr : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"attr","hash":{},"data":data}) : helper)))
    + "\" class=\"sorting-control "
    + alias4(((helper = (helper = helpers.viewId || (depth0 != null ? depth0.viewId : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"viewId","hash":{},"data":data}) : helper)))
    + " "
    + alias4(((helper = (helper = helpers.order || (depth0 != null ? depth0.order : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"order","hash":{},"data":data}) : helper)))
    + "\">\n"
    + ((stack1 = helpers["if"].call(alias1,(depth0 != null ? depth0.routeName : depth0),{"name":"if","hash":{},"fn":container.program(2, data, 0),"inverse":container.program(4, data, 0),"data":data})) != null ? stack1 : "")
    + "  </th>\n";
},"2":function(container,depth0,helpers,partials,data) {
    var helper, alias1=depth0 != null ? depth0 : {}, alias2=helpers.helperMissing, alias3=container.escapeExpression;

  return "      <a href=\""
    + alias3((helpers.url || (depth0 && depth0.url) || alias2).call(alias1,(depth0 != null ? depth0.routeName : depth0),(depth0 != null ? depth0.routeParams : depth0),(depth0 != null ? depth0.nextState : depth0),{"name":"url","hash":{},"data":data}))
    + "\">\n        <span>"
    + alias3(((helper = (helper = helpers.text || (depth0 != null ? depth0.text : depth0)) != null ? helper : alias2),(typeof helper === "function" ? helper.call(alias1,{"name":"text","hash":{},"data":data}) : helper)))
    + "</span><span class=\"indicator\"></span>\n      </a>\n";
},"4":function(container,depth0,helpers,partials,data) {
    var helper;

  return "      <span>"
    + container.escapeExpression(((helper = (helper = helpers.text || (depth0 != null ? depth0.text : depth0)) != null ? helper : helpers.helperMissing),(typeof helper === "function" ? helper.call(depth0 != null ? depth0 : {},{"name":"text","hash":{},"data":data}) : helper)))
    + "</span>\n";
},"compiler":[7,">= 4.0.0"],"main":function(container,depth0,helpers,partials,data) {
    var stack1, alias1=depth0 != null ? depth0 : {};

  return ((stack1 = helpers["with"].call(alias1,helpers.lookup.call(alias1,(depth0 != null ? depth0.sortInfo : depth0),(depth0 != null ? depth0.attr : depth0),{"name":"lookup","hash":{},"data":data}),{"name":"with","hash":{},"fn":container.program(1, data, 0),"inverse":container.noop,"data":data})) != null ? stack1 : "");
},"useData":true}));

this["Handlebars"]["notification"] = Handlebars.template({"compiler":[7,">= 4.0.0"],"main":function(container,depth0,helpers,partials,data) {
    var helper;

  return "<button type=\"button\" class=\"close\" data-dismiss=\"alert\" aria-hidden=\"true\">&times;</button>\n"
    + container.escapeExpression(((helper = (helper = helpers.message || (depth0 != null ? depth0.message : depth0)) != null ? helper : helpers.helperMissing),(typeof helper === "function" ? helper.call(depth0 != null ? depth0 : {},{"name":"message","hash":{},"data":data}) : helper)))
    + "\n";
},"useData":true});

return this["Handlebars"];

});