import json
from icecream import ic

ic.configureOutput(prefix='Debug | ')
ic.disable()

# Recursive Nested lookup into a JSON object for a key
def searchForKeyValues_v1(data, values, trail, targetKey):

    if isinstance(data, dict):
        for currKey, currValue in data.items():
            trail.append(currKey)
            if currKey == targetKey:
                values.append(currValue)
            elif isinstance(currValue, (dict, list)):
                searchForKeyValues_v1(currValue, values, trail, targetKey)
    elif isinstance(data, list):
        for currItem in data:
            searchForKeyValues_v1(currItem, values, trail, targetKey)
    
    return values

# Recursive Nested lookup into a JSON object for a key
def searchForKeyValues_v2(data, values, trail, targetKey):

    if isinstance(data, dict):
        for currKey, currValue in data.items():
            trail.append(currKey)
            if isinstance(currValue, (dict, list)):
                searchForKeyValues_v2(currValue, values, trail, targetKey)
            elif currKey == targetKey:
                values.append(currValue)
    elif isinstance(data, list):
        for currItem in data:
            searchForKeyValues_v2(currItem, values, trail, targetKey)
    
    return values


def nestedLookup(jsonData, targetKey,opt):
    values = []
    trail = []

    if opt  == 1:
        result = searchForKeyValues_v1(jsonData, values, trail, targetKey)
    else:
        result = searchForKeyValues_v2(jsonData, values, trail, targetKey)

    ic(trail)

    return result


# main()
if __name__ == '__main__':

    print("\n<<<< Running version 1 >>>>\n")

    object1 = {'a': {'b': {'c':'d'}}}
    print("Key ", 'a -', "Value - ", nestedLookup(object1, 'a',1))
    print("Key ", 'b -', "Value - ", nestedLookup(object1, 'b',1))    
    print("Key ", 'c -', "Value - ", nestedLookup(object1, 'c',1))
    print("Key ", 'x -', "Value - ", nestedLookup(object1, 'x',1))

    object2 = {'x': {'y': {'z':'a'}}}
    print("Key ", 'x -', "Value - ", nestedLookup(object2, 'x',1))
    print("Key ", 'y -', "Value - ", nestedLookup(object2, 'y',1))    
    print("Key ", 'z -', "Value - ", nestedLookup(object2, 'z',1))
    print("Key ", 'a -', "Value - ", nestedLookup(object2, 'a',1))

    print("\n<<<< Running version 2 >>>>\n")

    print("Key ", 'a -', "Value - ", nestedLookup(object, 'a',2))
    print("Key ", 'b -', "Value - ", nestedLookup(object, 'b',2))    
    print("Key ", 'c -', "Value - ", nestedLookup(object, 'c',2))
    print("Key ", 'x -', "Value - ", nestedLookup(object, 'x',2))

    print("Key ", 'x -', "Value - ", nestedLookup(object2, 'x',2))
    print("Key ", 'y -', "Value - ", nestedLookup(object2, 'y',2))    
    print("Key ", 'z -', "Value - ", nestedLookup(object2, 'z',2))
    print("Key ", 'a -', "Value - ", nestedLookup(object2, 'a',2))


