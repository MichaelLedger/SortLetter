//
//  SQLiteHelper.swift
//  SortLetter
//
//  Created by MountainX on 2019/2/22.
//  Copyright © 2019 MTX Software Technology Co.,Ltd. All rights reserved.
//

import SQLite

class SQLiteHelper: NSObject {
    // Singleton
    static let shareHelper = SQLiteHelper()
    
    func writeOxfordDictionaryToDatabase(oxfordDict: NSArray) {
        let dbPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        print("dbPath:\(dbPath)")
        var db: Connection!
        do {
            // Connecting to a Database
            db = try Connection("\(dbPath)/english-chinese.sqlite", readonly: false)
        } catch let error as NSError {
            print(error)
        }
        if db != nil {
            // Creating a Table
            // Expressions
            let id = Expression<Int64>("id")
            let word = Expression<String>("word")
            let mean = Expression<String>("mean")
            // Creating a Table
            let oxford = Table("Oxford")
            do {
                /*
                 CREATE TABLE IF NOT EXISTS "Oxford" (
                 "id" integer PRIMARY KEY AUTOINCREMENT NOT NULL,
                 "word" text UNIQUE NOT NULL,
                 "mean" text NOT NULL
                 );
                 */
                try db.run(oxford.create(ifNotExists: true) { t in
                    t.column(id, primaryKey: .autoincrement)// primary key
                    t.column(word, unique: true)// unique
                    t.column(mean, defaultValue: "")
                })
            } catch let error as NSError {
                print(error)
            }
            
            // Inserting Rows
            for dict in oxfordDict {
                let dict = dict as! [String : String]
                do {
                    try db.run(oxford.insert(word <- dict.keys.first!, mean <- dict.values.first!))
                } catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
                    print("constraint failed: \(message), in \(String(describing: statement))")
                } catch let error {
                    print("insertion failed: \(error)")
                }
            }
            
            // Selecting Rows
            do {
                for dict in try db.prepare(oxford) {
                    do {
                        print("\(try dict.get(word)) : \(try dict.get(mean))")
                    } catch let error {
                        print("Selection failed: \(error)")
                    }
                }
            } catch let error {
                print("Preparation failed: \(error)")
            }
        }
    }
    
    func searchFromOxfordDict(keyword: String) -> (String, String?, Bool) {
        let dbPath = Bundle.main.path(forResource: "english-chinese", ofType: "sqlite")
        var db: Connection!
        do {
            // Connecting to a Database
            db = try Connection(dbPath!, readonly: true)
        } catch let error as NSError {
            print(error)
        }
        
        let oxford = Table("Oxford")
//        let id = Expression<Int64>("id")
        let word = Expression<String>("word")
        let mean = Expression<String>("mean")
        
        // Selecting Rows
//        do {
//            for dict in try db.prepare(oxford) {
//                do {
//                    print("\(try dict.get(word)) : \(try dict.get(mean))")
//                } catch let error {
//                    print("Selection failed: \(error)")
//                }
//            }
//        } catch let error {
//            print("Preparation failed: \(error)")
//        }
        
        // Filtering Rows
        // SELECT * FROM "Oxford" WHERE ("word" LIKE keyword)
//        let query = oxford.filter(word.like("\(keyword)")).limit(1)
//        do {
//            for dict in try db.prepare(query) {
//                let meaning = try dict.get(mean)
//                return meaning
//            }
//        } catch let error {
//            print("Search failed: \(error)")
//        }
        
        var meaning: String?
        
        // 精准查询
        let query = oxford.select(word, mean).filter(word.lowercaseString == keyword.lowercased()).limit(1)
        do {
            // pluck the first row by passing a query to the 'pluck' function on a database connection.
            for dict in try db.prepare(query) {
                meaning = try dict.get(mean)
                let keyword = try dict.get(word)
                return (keyword ,meaning, true)
            }
        } catch let error {
            print("Search failed: \(error)")
        }
        
        if meaning == nil {
            // 模糊查询1 ('%'为占位符)
            let query = oxford.select(word, mean).filter(word.lowercaseString.like("\(keyword.lowercased())")).limit(1)
            do {
                // pluck the first row by passing a query to the 'pluck' function on a database connection.
                for dict in try db.prepare(query) {
                    meaning = try dict.get(mean)
                    let keyword = try dict.get(word)
                    return (keyword, meaning, false)
                }
            } catch let error {
                print("Search failed: \(error)")
            }
        }
        
        if meaning == nil {
            // 模糊查询2 ('%'为占位符)
            let query = oxford.select(word, mean).filter(word.lowercaseString.like("\(keyword.lowercased())%")).limit(1)
            do {
                // pluck the first row by passing a query to the 'pluck' function on a database connection.
                for dict in try db.prepare(query) {
                    meaning = try dict.get(mean)
                    let keyword = try dict.get(word)
                    return (keyword, meaning, false)
                }
            } catch let error {
                print("Search failed: \(error)")
            }
        }
        
        if meaning == nil {
            // 模糊查询3 ('%'为占位符)
            let query = oxford.select(word, mean).filter(word.lowercaseString.like("%\(keyword.lowercased())")).limit(1)
            do {
                // pluck the first row by passing a query to the 'pluck' function on a database connection.
                for dict in try db.prepare(query) {
                    meaning = try dict.get(mean)
                    let keyword = try dict.get(word)
                    return (keyword, meaning, false)
                }
            } catch let error {
                print("Search failed: \(error)")
            }
        }
        
        if meaning == nil {
            // 模糊查询4 ('%'为占位符)
            let query = oxford.select(word, mean).filter(word.lowercaseString.like("%\(keyword.lowercased())%")).limit(1)
            do {
                // pluck the first row by passing a query to the 'pluck' function on a database connection.
                for dict in try db.prepare(query) {
                    meaning = try dict.get(mean)
                    let keyword = try dict.get(word)
                    return (keyword, meaning, false)
                }
            } catch let error {
                print("Search failed: \(error)")
            }
        }
        
        return (keyword, meaning, false)
    }
}
