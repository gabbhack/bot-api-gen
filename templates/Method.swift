{% for line in method.description %}
/// {{ line }}
{% endfor %}
///
/// [Source]({{ method.documentation_link }})
public struct {{ method.name }} {
    {% for argument in method.arguments %}
    {% for line in argument.description %}
    /// {{ line }}
    {% endfor %}
    public let {{ argument.name }}: {{ argument.type }}
    {% endfor %}
}
