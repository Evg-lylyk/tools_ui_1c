#Использовать v8runner
#Использовать v8find
#Использовать fs
#Использовать tempfiles

Перем КаталогИсходныхФайлов;
Перем КаталогИсходныхФайловРезультирующегоРасширения;
Перем ВариантСборки Экспорт;
Перем КаталогРезультатаСборки;
Перем Лог;
Перем МенеджерВременныхФайлов;

Процедура УстановитьКаталогИсходныхФайлов(Каталог) Экспорт
	КаталогИсходныхФайлов=Каталог;
КонецПроцедуры

Процедура УстановитьКаталогРезультатаСборки(Каталог) Экспорт
	КаталогРезультатаСборки = Каталог;
	МенеджерВременныхФайлов.БазовыйКаталог = ОбъединитьПути(КаталогРезультатаСборки, "tmp");
	
КонецПроцедуры

Процедура УстановитьЛог(НовыйЛог) Экспорт
	Лог=НовыйЛог;
КонецПроцедуры

Процедура УдалитьОбъектыИзОписанияПодсистем(КаталогПодсистем, УдаляемыеОбъекты)
	ПроцессорXML = Новый СериализаторXML();
	
	МассивФайловПодсистем = НайтиФайлы(КаталогПодсистем, "*.xml", Ложь);
	Для Каждого ФайлПодсистемы Из МассивФайловПодсистем Цикл
		ИмяПодсистемы = ФайлПодсистемы.ИмяБезРасширения;
		
		
		ОписаниеПодсистемы = ПроцессорXML.ПрочитатьИзФайла(ФайлПодсистемы.ПолноеИмя);
		СоставПодсистемы = ОписаниеПодсистемы["MetaDataObject"]._Элементы["Subsystem"]._Элементы["Properties"]["Content"];
		
		ЕстьИзменения=Ложь;
		Если ТипЗнч(СоставПодсистемы)=Тип("Массив") Тогда
			ИндексМассива = СоставПодсистемы.Количество() - 1;
			Пока ИндексМассива >= 0 Цикл
				ЭлементСостава = СоставПодсистемы[ИндексМассива];
				Для Каждого Эл Из ЭлементСостава Цикл
					Ключ = Эл.Ключ;
					Значение = Эл.Значение;
				КонецЦикла;
				
				Если УдаляемыеОбъекты.Найти(Значение._Значение) <> Неопределено Тогда
					СоставПодсистемы.Удалить(ИндексМассива);
					ЕстьИзменения=Истина;
				КонецЕсли;
				
				ИндексМассива = ИндексМассива - 1;
			КонецЦикла;		
		Иначе
			
			КлючиКУдалению = Новый Массив;
			Для Каждого ЭлементСостава Из СоставПодсистемы Цикл
				Ключ = ЭлементСостава.Ключ;
				Значение = ЭлементСостава.Значение;
				
				Если УдаляемыеОбъекты.Найти(Значение._Значение) <> Неопределено Тогда
					КлючиКУдалению.Добавить(Ключ);
				КонецЕсли;
			КонецЦикла;		
			
			Для Каждого Ключ Из КлючиКУдалению Цикл
				СоставПодсистемы.Удалить(Ключ);
				ЕстьИзменения=Истина;
			КонецЦикла;
		КонецЕсли;
		Если ЕстьИзменения Тогда
			ПроцессорXML.ЗаписатьВФайл(ОписаниеПодсистемы, ФайлПодсистемы.ПолноеИмя, Истина);
		КонецЕсли;
		ПодчиненныеПодсистемы = ОписаниеПодсистемы["MetaDataObject"]._Элементы["Subsystem"]._Элементы["ChildObjects"];
		Если ПодчиненныеПодсистемы<>Неопределено Тогда
			Для Каждого ЭлементПодчиненнойПодсистемы Из ПодчиненныеПодсистемы Цикл
				УдалитьОбъектыИзОписанияПодсистем(ОбъединитьПути(КаталогПодсистем, ИмяПодсистемы, "Subsystems"), УдаляемыеОбъекты);
			КонецЦикла;
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры

Процедура УдалитьСтруктурыТаблицДанных(ОписаниеОсновногоРасширения)
	ПодчиненныеОбъектыОсновногоРасширения = ОписаниеОсновногоРасширения["MetaDataObject"]._Элементы["Configuration"]._Элементы["ChildObjects"];
	
	УдаляемыеОбъекты = Новый Массив;
	УдаляемыеОбъекты.Добавить("Catalog.УИ_Алгоритмы");
	
	РазложенныеУдаляемыеОбъекты = Новый Массив;
	Для Каждого ИмяОбъекта Из УдаляемыеОбъекты Цикл
		СтруктураОъекта = Новый Структура;
		
		массивИмени = СтрРазделить(ИмяОбъекта, ".");
		СтруктураОъекта.Вставить("Вид",массивИмени[0]);
		СтруктураОъекта.Вставить("Имя",массивИмени[1]);
		
		РазложенныеУдаляемыеОбъекты.Добавить(СтруктураОъекта);
	КонецЦикла;
	
	// 1. Нужно удалить данные об объектах из основного расширения
	ИндексМассива = ПодчиненныеОбъектыОсновногоРасширения.Количество() - 1;
	Пока ИндексМассива >= 0 Цикл
		ПодчиненныйОбъект=ПодчиненныеОбъектыОсновногоРасширения[ИндексМассива];
		Для Каждого Эл Из ПодчиненныйОбъект Цикл
			Ключ = Эл.Ключ;
			Значение = Эл.Значение;
		КонецЦикла;
		
		УдаляемОбъект=Ложь;
		Для Каждого УдОбъект ИЗ РазложенныеУдаляемыеОбъекты Цикл
			Если УдОбъект.Вид = Ключ
				И УдОбъект.Имя = Значение Тогда
				УдаляемОбъект = Истина;
				Прервать;
			КонецЕсли;
		КонецЦикла;
		Если УдаляемОбъект Тогда
			ПодчиненныеОбъектыОсновногоРасширения.Удалить(ИндексМассива);
		КонецЕсли;
		
		ИндексМассива = ИндексМассива - 1;
	КонецЦикла;
	
	// 2. Удалить папки со структурами данных
	УдалитьФайлы(ОбъединитьПути(КаталогИсходныхФайловРезультирующегоРасширения, "Catalogs"));
	
	// 3. Удалить объекты из подсистем
	УдалитьОбъектыИзОписанияПодсистем(ОбъединитьПути(КаталогИсходныхФайловРезультирующегоРасширения, "Subsystems"), УдаляемыеОбъекты);
КонецПроцедуры

Процедура ВыполнитьСборкуИсходников() Экспорт
	
	КаталогИсходныхФайловРезультирующегоРасширения = КаталогРезультатаСборки;
	
	ФС.КопироватьСодержимоеКаталога(ОбъединитьПути(КаталогИсходныхФайлов, "Инструменты"), КаталогИсходныхФайловРезультирующегоРасширения);
	
	ПроцессорXML = Новый СериализаторXML();
	
	ОписаниеОсновногоРасширения = ПроцессорXML.ПрочитатьИзФайла(ОбъединитьПути(КаталогИсходныхФайловРезультирующегоРасширения, "Configuration.xml"));
	// ОписаниеРасширенияИнтеграции = ПроцессорXML.ПрочитатьИзФайла(ОбъединитьПути(ВременныйКаталогРасширенияИнтеграции, "Configuration.xml"));
	
	СвойстваКонфигурацииОсновногоРасширения = ОписаниеОсновногоРасширения["MetaDataObject"]._Элементы["Configuration"]._Элементы["Properties"];
	Если ЗначениеЗаполнено(ВариантСборки.СуффиксИмени) Тогда
		СвойстваКонфигурацииОсновногоРасширения["Name"] = СвойстваКонфигурацииОсновногоРасширения["Name"] + "_" + ВариантСборки.СуффиксИмени;
	КонецЕсли;
	Если ЗначениеЗаполнено(ВариантСборки.СуффиксСинонима) Тогда
		СвойстваКонфигурацииОсновногоРасширения["Synonym"]["v8:item"]["v8:content"] = СвойстваКонфигурацииОсновногоРасширения["Synonym"]["v8:item"]["v8:content"] + " " + ВариантСборки.СуффиксСинонима;
	КонецЕсли;
	
	Если ВариантСборки.ИсключатьТаблицыБД Тогда
		УдалитьСтруктурыТаблицДанных(ОписаниеОсновногоРасширения);
		
		СвойстваКонфигурацииОсновногоРасширения["ConfigurationExtensionCompatibilityMode"] = "Version8_3_10";
		// < ConfigurationExtensionCompatibilityMode > Version8_3_9 < /ConfigurationExtensionCompatibilityMode > 
	КонецЕсли;
	ПодчиненныеОбъектыОсновногоРасширения=ОписаниеОсновногоРасширения["MetaDataObject"]._Элементы["Configuration"]._Элементы["ChildObjects"];
	// ПодчиненныеОбъектыРасширенияИнтеграции = ОписаниеРасширенияИнтеграции["MetaDataObject"]._Элементы["Configuration"]._Элементы["ChildObjects"];
	
	// Для Каждого ПодчиненныйОбъект ИЗ ПодчиненныеОбъектыРасширенияИнтеграции Цикл
	// 	Если ТипЗнч(ПодчиненныйОбъект) = Тип("КлючИЗначение") Тогда
	// 		Ключ = ПодчиненныйОбъект.Ключ;
	// 		Значение=ПодчиненныйОбъект.Значение;
	// 	Иначе
	// 		Ключ = ПодчиненныйОбъект[0].Ключ;
	// 		Значение=ПодчиненныйОбъект[0].Значение;
	// 	КонецЕсли;
	// 	Если ТипЗнч(ПодчиненныеОбъектыОсновногоРасширения) = Тип("Соответствие") Тогда
	// 		ПодчиненныеОбъектыОсновногоРасширения.Вставить(Ключ, Значение);
	// 	Иначе
	
	// 		СоответствиеВставки = Новый Соответствие();
	// 		СоответствиеВставки.Вставить(Ключ, Значение);
	// 		ПодчиненныеОбъектыОсновногоРасширения.Добавить(СоответствиеВставки);
	// 	КонецЕсли;
	
	// 	//Теперь нужно скопировать нужную папку
	// 	ИмяКаталогаОбъекта="";
	// 	Если Ключ = "CommonModule" Тогда
	// 		ИмяКаталогаОбъекта = "CommonModules";
	// 	КонецЕсли;
	
	// 	Если Не ЗначениеЗаполнено(ИмяКаталогаОбъекта) Тогда
	// 		Лог.Ошибка("Не удалось определить местоположения объекта "+Ключ+" "+Значение);
	// 		Продолжить;
	// 	КонецЕсли;
	
	// 	//Основной файл
	// 	КопироватьФайл(
	// 	ОбъединитьПути(ВременныйКаталогРасширенияИнтеграции, ИмяКаталогаОбъекта, Значение + ".xml"), 
	// 	ОбъединитьПути(КаталогИсходныхФайловРезультирующегоРасширения, ИмяКаталогаОбъекта, Значение + ".xml"));
	
	// 	ФС.КопироватьСодержимоеКаталога(
	// 	ОбъединитьПути(ВременныйКаталогРасширенияИнтеграции, ИмяКаталогаОбъекта, Значение), 
	// 	ОбъединитьПути(КаталогИсходныхФайловРезультирующегоРасширения, ИмяКаталогаОбъекта, Значение));
	// КонецЦикла;
	
	ПроцессорXML.ЗаписатьВФайл(ОписаниеОсновногоРасширения, ОбъединитьПути(КаталогИсходныхФайловРезультирующегоРасширения, "Configuration.xml"), Истина);
	
	МенеджерВременныхФайлов.Удалить();
	Если ЗначениеЗаполнено(МенеджерВременныхФайлов.БазовыйКаталог) Тогда
		УдалитьФайлы(МенеджерВременныхФайлов.БазовыйКаталог);
	КонецЕсли;
	
КонецПроцедуры

Процедура ВыполнитьСозданиеБинарногоФайла(Знач ИмяФайлаРасширения) Экспорт
	
	ИмяВременнойБазы = МенеджерВременныхФайлов.СоздатьКаталог();
	ФС.ОбеспечитьКаталог(ИмяВременнойБазы);
	
	Конфигуратор = Новый УправлениеКонфигуратором();
	Лог.Информация(СтрШаблон("Создаю временную базу %1", ИмяВременнойБазы));
	Конфигуратор.СоздатьФайловуюБазу(ИмяВременнойБазы);
	
	Конфигуратор.УстановитьКонтекст("/F" + ИмяВременнойБазы, "", "");
	
	Лог.Информация(СтрШаблон("Загружаю исходные файлы в базу"));
	Конфигуратор.ЗагрузитьРасширениеИзФайлов(КаталогИсходныхФайловРезультирующегоРасширения, "УниверсальныеИнструменты");
	
	Конфигуратор.ВыгрузитьРасширениеВФайл(ИмяФайлаРасширения,  "УниверсальныеИнструменты");
	
	МенеджерВременныхФайлов.Удалить();
	УдалитьФайлы(МенеджерВременныхФайлов.БазовыйКаталог);
КонецПроцедуры

Лог = Новый Лог("app.build.tools_ui_1c");
МенеджерВременныхФайлов = Новый МенеджерВременныхФайлов();
