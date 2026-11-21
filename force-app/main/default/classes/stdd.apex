StudentWrapper stdWrapper = new StudentWrapper();

stdWrapper.std = new Student();

stdWrapper.std.Name = 'John Doe';
stdWrapper.std.Age = 20;
stdWrapper.isSelected = true;

System.debug('Student Name: ' + stdWrapper.std.Name);
System.debug('Student Age: ' + stdWrapper.std.Age);
System.debug('Is Selected: ' + stdWrapper.isSelected);