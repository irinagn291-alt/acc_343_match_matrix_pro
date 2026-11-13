"""Standard OpenStep project output, including references used by the factory CI."""
import json
import re


def prepare(document):
    objects = document['objects']
    for item in objects.values():
        if item.get('isa') == 'XCBuildConfiguration':
            settings = item['buildSettings']
            for key in ['CODE_SIGNING_ALLOWED', 'CODE_SIGNING_REQUIRED', 'CODE_SIGN_IDENTITY']:
                settings.pop(key, None)
            if not settings.get('DEVELOPMENT_TEAM'):
                settings.pop('DEVELOPMENT_TEAM', None)
        if item.get('isa') == 'PBXNativeTarget' and item.get('productType') in ['com.apple.product-type.application', 'com.apple.product-type.app-extension']:
            for reference in objects[item['buildConfigurationList']]['buildConfigurations']:
                objects[reference]['buildSettings']['CODE_SIGN_STYLE'] = 'Automatic'
    return document


def serialize(document):
    objects = document['objects']
    labels = {}
    for key, value in objects.items():
        label = value.get('name') or value.get('path') or value.get('isa', 'Object')
        labels[key] = ' '.join(str(label).replace('*/', '').split())

    def scalar(value, key=''):
        text = str(value)
        if text in labels:
            return text + ' /* ' + labels[text] + ' */'
        if key != 'productType' and re.fullmatch(r'[A-Za-z0-9_./]+', text):
            return text
        return json.dumps(text, ensure_ascii=False)

    def render(value, level=0, key=''):
        if isinstance(value, dict):
            lines = ['{']
            for name, item in value.items():
                lines.append('\t' * (level + 1) + scalar(name) + ' = ' + render(item, level + 1, name) + ';')
            lines.append('\t' * level + '}')
            return '\n'.join(lines)
        if isinstance(value, list):
            return '(\n' + ''.join('\t' * (level + 1) + render(item, level + 1) + ',\n' for item in value) + '\t' * level + ')'
        return scalar(value, key)

    return '// !$*UTF8*$!\n' + render(document) + '\n'
