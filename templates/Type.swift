import Foundation

{% if type.isEnum %}
{% for line in type.description %}
/// {{ line }}
{% endfor %}
///
/// [Source]({{ type.documentation_link }})
public enum {{ type.name }}: Codable {
    {% for variant in type.variants %}
    case {{ variant.name }}({{ variant.type }})
    {% endfor %}
}
{% else %}
{% for line in type.description %}
/// {{ line }}
{% endfor %}
///
/// [Source]({{ type.documentation_link }})
public struct {{ type.name }}: Codable {
    {% for property in type.properties %}
    {% for line in property.description %}
    /// {{ line }}
    {% endfor %}
    public let {{ property.name }}: {{ property.type }}
    {% endfor %}
}
{% endif %}
