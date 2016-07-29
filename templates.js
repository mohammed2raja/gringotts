define(['handlebars'], function(Handlebars) {

this["Handlebars"] = this["Handlebars"] || {};

Handlebars.registerPartial("pagination", Handlebars.template({"1":function(container,depth0,helpers,partials,data) {
    var stack1, helper, alias1=depth0 != null ? depth0 : {}, alias2=helpers.helperMissing, alias3=container.escapeExpression;

  return "    <a href=\""
    + alias3((helpers.url || (depth0 && depth0.url) || alias2).call(alias1,(depth0 != null ? depth0.routeName : depth0),(depth0 != null ? depth0.routeParams : depth0),(depth0 != null ? depth0.prevState : depth0),{"name":"url","hash":{},"data":data}))
    + "\"\n       class=\"prev-page "
    + ((stack1 = helpers.unless.call(alias1,(depth0 != null ? depth0.multiPaged : depth0),{"name":"unless","hash":{},"fn":container.program(2, data, 0),"inverse":container.program(4, data, 0),"data":data})) != null ? stack1 : "")
    + "\">\n      "
    + alias3((helpers.icon || (depth0 && depth0.icon) || alias2).call(alias1,"atlas-arrow-thin-up","rotate-left",{"name":"icon","hash":{},"data":data}))
    + "\n    </a>\n    <strong>"
    + alias3(((helper = (helper = helpers.range || (depth0 != null ? depth0.range : depth0)) != null ? helper : alias2),(typeof helper === "function" ? helper.call(alias1,{"name":"range","hash":{},"data":data}) : helper)))
    + "</strong>\n    <a href=\""
    + alias3((helpers.url || (depth0 && depth0.url) || alias2).call(alias1,(depth0 != null ? depth0.routeName : depth0),(depth0 != null ? depth0.routeParams : depth0),(depth0 != null ? depth0.nextState : depth0),{"name":"url","hash":{},"data":data}))
    + "\"\n       class=\"next-page "
    + ((stack1 = helpers.unless.call(alias1,(depth0 != null ? depth0.multiPaged : depth0),{"name":"unless","hash":{},"fn":container.program(2, data, 0),"inverse":container.program(7, data, 0),"data":data})) != null ? stack1 : "")
    + "\">\n      "
    + alias3((helpers.icon || (depth0 && depth0.icon) || alias2).call(alias1,"atlas-arrow-thin-up","rotate-right",{"name":"icon","hash":{},"data":data}))
    + "\n    </a>\n";
},"2":function(container,depth0,helpers,partials,data) {
    return "hidden";
},"4":function(container,depth0,helpers,partials,data) {
    var stack1;

  return ((stack1 = helpers.unless.call(depth0 != null ? depth0 : {},(depth0 != null ? depth0.prev : depth0),{"name":"unless","hash":{},"fn":container.program(5, data, 0),"inverse":container.noop,"data":data})) != null ? stack1 : "");
},"5":function(container,depth0,helpers,partials,data) {
    return "disabled-arrow";
},"7":function(container,depth0,helpers,partials,data) {
    var stack1;

  return ((stack1 = helpers.unless.call(depth0 != null ? depth0 : {},(depth0 != null ? depth0.next : depth0),{"name":"unless","hash":{},"fn":container.program(5, data, 0),"inverse":container.noop,"data":data})) != null ? stack1 : "");
},"compiler":[7,">= 4.0.0"],"main":function(container,depth0,helpers,partials,data) {
    var stack1, helper, alias1=depth0 != null ? depth0 : {};

  return "<div class=\"pagination-controls "
    + container.escapeExpression(((helper = (helper = helpers.viewId || (depth0 != null ? depth0.viewId : depth0)) != null ? helper : helpers.helperMissing),(typeof helper === "function" ? helper.call(alias1,{"name":"viewId","hash":{},"data":data}) : helper)))
    + "\">\n"
    + ((stack1 = helpers["if"].call(alias1,(depth0 != null ? depth0.count : depth0),{"name":"if","hash":{},"fn":container.program(1, data, 0),"inverse":container.noop,"data":data})) != null ? stack1 : "")
    + "</div>\n";
},"useData":true}));

Handlebars.registerPartial("progressPulse", Handlebars.template({"compiler":[7,">= 4.0.0"],"main":function(container,depth0,helpers,partials,data) {
    var helper;

  return "<div class=\"progress-pulse "
    + container.escapeExpression(((helper = (helper = helpers["class"] || (depth0 != null ? depth0["class"] : depth0)) != null ? helper : helpers.helperMissing),(typeof helper === "function" ? helper.call(depth0 != null ? depth0 : {},{"name":"class","hash":{},"data":data}) : helper)))
    + "\">\n  <div class=\"overlay\"></div>\n  <div class=\"animation\">\n    <span class=\"circle\"></span>\n    <span class=\"circle\"></span>\n    <span class=\"circle\"></span>\n  </div>\n</div>\n";
},"useData":true}));

Handlebars.registerPartial("sortTableHeader", Handlebars.template({"1":function(container,depth0,helpers,partials,data) {
    var helper, alias1=depth0 != null ? depth0 : {}, alias2=helpers.helperMissing, alias3="function", alias4=container.escapeExpression;

  return "  <th data-sort=\""
    + alias4(((helper = (helper = helpers.attr || (depth0 != null ? depth0.attr : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"attr","hash":{},"data":data}) : helper)))
    + "\" class=\"sorting-control "
    + alias4(((helper = (helper = helpers.viewId || (depth0 != null ? depth0.viewId : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"viewId","hash":{},"data":data}) : helper)))
    + "\">\n    <a href=\""
    + alias4((helpers.url || (depth0 && depth0.url) || alias2).call(alias1,(depth0 != null ? depth0.routeName : depth0),(depth0 != null ? depth0.routeParams : depth0),(depth0 != null ? depth0.nextState : depth0),{"name":"url","hash":{},"data":data}))
    + "\" class=\""
    + alias4(((helper = (helper = helpers.order || (depth0 != null ? depth0.order : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"order","hash":{},"data":data}) : helper)))
    + "\">\n      <span>"
    + alias4(((helper = (helper = helpers.text || (depth0 != null ? depth0.text : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"text","hash":{},"data":data}) : helper)))
    + "</span><span class=\"indicator\"></span>\n    </a>\n  </th>\n";
},"compiler":[7,">= 4.0.0"],"main":function(container,depth0,helpers,partials,data) {
    var stack1, alias1=depth0 != null ? depth0 : {};

  return ((stack1 = helpers["with"].call(alias1,helpers.lookup.call(alias1,(depth0 != null ? depth0.sortInfo : depth0),(depth0 != null ? depth0.attr : depth0),{"name":"lookup","hash":{},"data":data}),{"name":"with","hash":{},"fn":container.program(1, data, 0),"inverse":container.noop,"data":data})) != null ? stack1 : "");
},"useData":true}));

this["Handlebars"]["dialog"] = Handlebars.template({"1":function(container,depth0,helpers,partials,data) {
    var helper;

  return "      <div class=\"modal-header\">\n        <button type=\"button\" class=\"close\" data-dismiss=\"modal\" aria-label=\"Close\">\n          <span aria-hidden=\"true\">&times;</span>\n        </button>\n        <h4 class=\"modal-title\">"
    + container.escapeExpression(((helper = (helper = helpers.title || (depth0 != null ? depth0.title : depth0)) != null ? helper : helpers.helperMissing),(typeof helper === "function" ? helper.call(depth0 != null ? depth0 : {},{"name":"title","hash":{},"data":data}) : helper)))
    + "</h4>\n      </div>\n";
},"3":function(container,depth0,helpers,partials,data) {
    var helper, alias1=depth0 != null ? depth0 : {}, alias2=helpers.helperMissing, alias3="function", alias4=container.escapeExpression;

  return "        <button type=\"button\" class=\"btn "
    + alias4(((helper = (helper = helpers.className || (depth0 != null ? depth0.className : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"className","hash":{},"data":data}) : helper)))
    + "\" data-dismiss=\"modal\">"
    + alias4(((helper = (helper = helpers.text || (depth0 != null ? depth0.text : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"text","hash":{},"data":data}) : helper)))
    + "</button>\n";
},"compiler":[7,">= 4.0.0"],"main":function(container,depth0,helpers,partials,data) {
    var stack1, helper, alias1=depth0 != null ? depth0 : {};

  return "<div class=\"modal-dialog\" role=\"document\">\n  <div class=\"modal-content\">\n"
    + ((stack1 = helpers["if"].call(alias1,(depth0 != null ? depth0.title : depth0),{"name":"if","hash":{},"fn":container.program(1, data, 0),"inverse":container.noop,"data":data})) != null ? stack1 : "")
    + "    <div class=\"modal-body\"><p>"
    + container.escapeExpression(((helper = (helper = helpers.text || (depth0 != null ? depth0.text : depth0)) != null ? helper : helpers.helperMissing),(typeof helper === "function" ? helper.call(alias1,{"name":"text","hash":{},"data":data}) : helper)))
    + "</p></div>\n    <div class=\"modal-footer\">\n"
    + ((stack1 = helpers.each.call(alias1,(depth0 != null ? depth0.buttons : depth0),{"name":"each","hash":{},"fn":container.program(3, data, 0),"inverse":container.noop,"data":data})) != null ? stack1 : "")
    + "    </div>\n  </div>\n</div>\n";
},"useData":true});

this["Handlebars"]["notification-undo"] = Handlebars.template({"compiler":[7,">= 4.0.0"],"main":function(container,depth0,helpers,partials,data) {
    var helper;

  return "&nbsp;&nbsp;<a class=\"undo\" href=\"javascript:;\">"
    + container.escapeExpression(((helper = (helper = helpers.label || (depth0 != null ? depth0.label : depth0)) != null ? helper : helpers.helperMissing),(typeof helper === "function" ? helper.call(depth0 != null ? depth0 : {},{"name":"label","hash":{},"data":data}) : helper)))
    + "</a>\n";
},"useData":true});

this["Handlebars"]["notification"] = Handlebars.template({"compiler":[7,">= 4.0.0"],"main":function(container,depth0,helpers,partials,data) {
    var helper;

  return "<button type=\"button\" class=\"close\" data-dismiss=\"alert\" aria-hidden=\"true\">&times;</button>"
    + container.escapeExpression(((helper = (helper = helpers.message || (depth0 != null ? depth0.message : depth0)) != null ? helper : helpers.helperMissing),(typeof helper === "function" ? helper.call(depth0 != null ? depth0 : {},{"name":"message","hash":{},"data":data}) : helper)));
},"useData":true});

this["Handlebars"]["progress-dialog"] = Handlebars.template({"1":function(container,depth0,helpers,partials,data) {
    var stack1;

  return ((stack1 = helpers["if"].call(depth0 != null ? depth0 : {},(depth0 != null ? depth0.title : depth0),{"name":"if","hash":{},"fn":container.program(2, data, 0),"inverse":container.noop,"data":data})) != null ? stack1 : "");
},"2":function(container,depth0,helpers,partials,data) {
    var helper;

  return "    <div class=\"modal-header\">\n      <button type=\"button\" class=\"close\" data-dismiss=\"modal\" aria-label=\"Close\">\n        <span aria-hidden=\"true\">&times;</span>\n      </button>\n      <h4 class=\"modal-title\">"
    + container.escapeExpression(((helper = (helper = helpers.title || (depth0 != null ? depth0.title : depth0)) != null ? helper : helpers.helperMissing),(typeof helper === "function" ? helper.call(depth0 != null ? depth0 : {},{"name":"title","hash":{},"data":data}) : helper)))
    + "</h4>\n    </div>\n";
},"4":function(container,depth0,helpers,partials,data) {
    var stack1;

  return ((stack1 = helpers["if"].call(depth0 != null ? depth0 : {},(depth0 != null ? depth0.html : depth0),{"name":"if","hash":{},"fn":container.program(5, data, 0),"inverse":container.program(7, data, 0),"data":data})) != null ? stack1 : "");
},"5":function(container,depth0,helpers,partials,data) {
    var stack1, helper;

  return "    "
    + ((stack1 = ((helper = (helper = helpers.html || (depth0 != null ? depth0.html : depth0)) != null ? helper : helpers.helperMissing),(typeof helper === "function" ? helper.call(depth0 != null ? depth0 : {},{"name":"html","hash":{},"data":data}) : helper))) != null ? stack1 : "")
    + "\n";
},"7":function(container,depth0,helpers,partials,data) {
    var helper;

  return "    <p>"
    + container.escapeExpression(((helper = (helper = helpers.text || (depth0 != null ? depth0.text : depth0)) != null ? helper : helpers.helperMissing),(typeof helper === "function" ? helper.call(depth0 != null ? depth0 : {},{"name":"text","hash":{},"data":data}) : helper)))
    + "</p>\n";
},"9":function(container,depth0,helpers,partials,data) {
    var stack1;

  return "  <div class=\"modal-footer\">\n"
    + ((stack1 = helpers.each.call(depth0 != null ? depth0 : {},(depth0 != null ? depth0.buttons : depth0),{"name":"each","hash":{},"fn":container.program(10, data, 0),"inverse":container.noop,"data":data})) != null ? stack1 : "")
    + "  </div>\n";
},"10":function(container,depth0,helpers,partials,data) {
    var stack1, helper, alias1=depth0 != null ? depth0 : {}, alias2=helpers.helperMissing, alias3="function", alias4=container.escapeExpression;

  return "      <button type=\"button\" class=\"btn "
    + alias4(((helper = (helper = helpers.className || (depth0 != null ? depth0.className : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"className","hash":{},"data":data}) : helper)))
    + "\"\n          "
    + ((stack1 = helpers.unless.call(alias1,((stack1 = (depth0 != null ? depth0.click : depth0)) != null ? stack1.prototype : stack1),{"name":"unless","hash":{},"fn":container.program(11, data, 0),"inverse":container.noop,"data":data})) != null ? stack1 : "")
    + ">"
    + alias4(((helper = (helper = helpers.text || (depth0 != null ? depth0.text : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"text","hash":{},"data":data}) : helper)))
    + "</button>\n";
},"11":function(container,depth0,helpers,partials,data) {
    return "data-dismiss=\"modal\"";
},"13":function(container,depth0,helpers,partials,data) {
    var stack1, helper, alias1=depth0 != null ? depth0 : {}, alias2=helpers.helperMissing;

  return "  <div class=\"modal-content "
    + container.escapeExpression(((helper = (helper = helpers.current || (depth0 != null ? depth0.current : depth0)) != null ? helper : alias2),(typeof helper === "function" ? helper.call(alias1,{"name":"current","hash":{},"data":data}) : helper)))
    + "-view fade"
    + ((stack1 = (helpers.ifequal || (depth0 && depth0.ifequal) || alias2).call(alias1,(depth0 != null ? depth0.state : depth0),(depth0 != null ? depth0.current : depth0),{"name":"ifequal","hash":{},"fn":container.program(14, data, 0),"inverse":container.noop,"data":data})) != null ? stack1 : "")
    + "\">\n"
    + ((stack1 = container.invokePartial(partials["@partial-block"],depth0,{"name":"@partial-block","data":data,"indent":"    ","helpers":helpers,"partials":partials,"decorators":container.decorators})) != null ? stack1 : "")
    + "  </div>\n";
},"14":function(container,depth0,helpers,partials,data) {
    return " in";
},"16":function(container,depth0,helpers,partials,data) {
    var stack1;

  return ((stack1 = container.invokePartial(partials.header,(depth0 != null ? depth0["default"] : depth0),{"name":"header","data":data,"indent":"    ","helpers":helpers,"partials":partials,"decorators":container.decorators})) != null ? stack1 : "")
    + "    <div class=\"modal-body\">\n"
    + ((stack1 = container.invokePartial(partials["body-content"],(depth0 != null ? depth0["default"] : depth0),{"name":"body-content","data":data,"indent":"      ","helpers":helpers,"partials":partials,"decorators":container.decorators})) != null ? stack1 : "")
    + "    </div>\n"
    + ((stack1 = container.invokePartial(partials.footer,(depth0 != null ? depth0["default"] : depth0),{"name":"footer","data":data,"indent":"    ","helpers":helpers,"partials":partials,"decorators":container.decorators})) != null ? stack1 : "")
    + ((stack1 = container.invokePartial(partials.progressPulse,depth0,{"name":"progressPulse","hash":{"class":"loading fade"},"data":data,"indent":"    ","helpers":helpers,"partials":partials,"decorators":container.decorators})) != null ? stack1 : "");
},"18":function(container,depth0,helpers,partials,data) {
    var stack1;

  return ((stack1 = container.invokePartial(partials.header,(depth0 != null ? depth0.progress : depth0),{"name":"header","data":data,"indent":"    ","helpers":helpers,"partials":partials,"decorators":container.decorators})) != null ? stack1 : "")
    + "    <div class=\"modal-body\">\n"
    + ((stack1 = container.invokePartial(partials["body-content"],(depth0 != null ? depth0.progress : depth0),{"name":"body-content","data":data,"indent":"      ","helpers":helpers,"partials":partials,"decorators":container.decorators})) != null ? stack1 : "")
    + ((stack1 = container.invokePartial(partials.progressPulse,depth0,{"name":"progressPulse","data":data,"indent":"      ","helpers":helpers,"partials":partials,"decorators":container.decorators})) != null ? stack1 : "")
    + "    </div>\n"
    + ((stack1 = container.invokePartial(partials.footer,(depth0 != null ? depth0.progress : depth0),{"name":"footer","data":data,"indent":"    ","helpers":helpers,"partials":partials,"decorators":container.decorators})) != null ? stack1 : "");
},"20":function(container,depth0,helpers,partials,data) {
    var stack1;

  return ((stack1 = container.invokePartial(partials.header,(depth0 != null ? depth0.error : depth0),{"name":"header","data":data,"indent":"    ","helpers":helpers,"partials":partials,"decorators":container.decorators})) != null ? stack1 : "")
    + "    <div class=\"modal-body\">\n"
    + ((stack1 = container.invokePartial(partials["body-content"],(depth0 != null ? depth0.error : depth0),{"name":"body-content","data":data,"indent":"      ","helpers":helpers,"partials":partials,"decorators":container.decorators})) != null ? stack1 : "")
    + "    </div>\n"
    + ((stack1 = container.invokePartial(partials.footer,(depth0 != null ? depth0.error : depth0),{"name":"footer","data":data,"indent":"    ","helpers":helpers,"partials":partials,"decorators":container.decorators})) != null ? stack1 : "");
},"22":function(container,depth0,helpers,partials,data) {
    var stack1;

  return ((stack1 = container.invokePartial(partials.header,(depth0 != null ? depth0.success : depth0),{"name":"header","data":data,"indent":"    ","helpers":helpers,"partials":partials,"decorators":container.decorators})) != null ? stack1 : "")
    + "    <div class=\"modal-body\">\n"
    + ((stack1 = container.invokePartial(partials["body-content"],(depth0 != null ? depth0.success : depth0),{"name":"body-content","data":data,"indent":"      ","helpers":helpers,"partials":partials,"decorators":container.decorators})) != null ? stack1 : "")
    + "    </div>\n"
    + ((stack1 = container.invokePartial(partials.footer,(depth0 != null ? depth0.success : depth0),{"name":"footer","data":data,"indent":"    ","helpers":helpers,"partials":partials,"decorators":container.decorators})) != null ? stack1 : "");
},"compiler":[7,">= 4.0.0"],"main":function(container,depth0,helpers,partials,data,blockParams,depths) {
    var stack1;

  return "\n\n\n\n<div class=\"modal-dialog\">\n"
    + ((stack1 = container.invokePartial(partials["modal-content"],depth0,{"name":"modal-content","hash":{"current":"default"},"fn":container.program(16, data, 0, blockParams, depths),"inverse":container.noop,"data":data,"helpers":helpers,"partials":partials,"decorators":container.decorators})) != null ? stack1 : "")
    + "\n"
    + ((stack1 = container.invokePartial(partials["modal-content"],depth0,{"name":"modal-content","hash":{"current":"progress"},"fn":container.program(18, data, 0, blockParams, depths),"inverse":container.noop,"data":data,"helpers":helpers,"partials":partials,"decorators":container.decorators})) != null ? stack1 : "")
    + "\n"
    + ((stack1 = container.invokePartial(partials["modal-content"],depth0,{"name":"modal-content","hash":{"current":"error"},"fn":container.program(20, data, 0, blockParams, depths),"inverse":container.noop,"data":data,"helpers":helpers,"partials":partials,"decorators":container.decorators})) != null ? stack1 : "")
    + "\n"
    + ((stack1 = container.invokePartial(partials["modal-content"],depth0,{"name":"modal-content","hash":{"current":"success"},"fn":container.program(22, data, 0, blockParams, depths),"inverse":container.noop,"data":data,"helpers":helpers,"partials":partials,"decorators":container.decorators})) != null ? stack1 : "")
    + "</div>\n";
},"main_d":  function(fn, props, container, depth0, data, blockParams, depths) {

  var decorators = container.decorators;

  fn = decorators.inline(fn,props,container,{"name":"inline","hash":{},"fn":container.program(1, data, 0, blockParams, depths),"inverse":container.noop,"args":["header"],"data":data}) || fn;
  fn = decorators.inline(fn,props,container,{"name":"inline","hash":{},"fn":container.program(4, data, 0, blockParams, depths),"inverse":container.noop,"args":["body-content"],"data":data}) || fn;
  fn = decorators.inline(fn,props,container,{"name":"inline","hash":{},"fn":container.program(9, data, 0, blockParams, depths),"inverse":container.noop,"args":["footer"],"data":data}) || fn;
  fn = decorators.inline(fn,props,container,{"name":"inline","hash":{},"fn":container.program(13, data, 0, blockParams, depths),"inverse":container.noop,"args":["modal-content"],"data":data}) || fn;
  return fn;
  }

,"useDecorators":true,"usePartial":true,"useData":true,"useDepths":true});

this["Handlebars"]["progress-success"] = Handlebars.template({"compiler":[7,">= 4.0.0"],"main":function(container,depth0,helpers,partials,data) {
    var stack1, alias1=container.escapeExpression;

  return alias1((helpers.icon || (depth0 && depth0.icon) || helpers.helperMissing).call(depth0 != null ? depth0 : {},"misc-sign-check",{"name":"icon","hash":{},"data":data}))
    + "\n<h1>"
    + alias1(container.lambda(((stack1 = (depth0 != null ? depth0.success : depth0)) != null ? stack1.text : stack1), depth0))
    + "</h1>\n";
},"useData":true});

return this["Handlebars"];

});