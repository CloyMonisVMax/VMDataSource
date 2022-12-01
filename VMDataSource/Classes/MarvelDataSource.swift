//
//  MarvelDataSource.swift
//  Marvel
//
//  Created by Cloy Vserv on 30/11/22.
//

import Foundation
import CoreData

let coreDispatchQueue = DispatchQueue(label: "com.marvel.coredata", attributes: .concurrent)

enum MarvelConstants: String {
    case objectModelname = "Marvel"
    case superHero = "SuperHero"
}

enum MarvelDataSourceError: Error{
    case noDataError
    case parsingError
}

public class MarvelDataSource {
    private let coreStack = MarvelDataStack(modelName: MarvelConstants.objectModelname.rawValue)
    private let limit = 5
    private var client: MarvelClient?
    public init() { }
    public func fetch(superHero: MarvelSuperHero) -> MarvelSuperHeroDetails? {
        guard let id = superHero.id else {
          return nil
        }
        let idd = Int32(id)
        var res = MarvelSuperHeroDetails()
        res.hero = superHero
        res.comics = self.comics(id: idd)
        res.series = self.series(id: idd)
        res.events = self.events(id: idd)
        res.urls = self.urls(id: idd)
        res.stories = self.stories(id: idd)
        return res
    }
    public func fetch(from index: Int, completion: @escaping (Result<[MarvelSuperHero],Error>) -> Void ) {
        coreDispatchQueue.async {
            self.fetchData(from: index) { result in
                switch result{
                case.success(let superHero):
                    var heros = [MarvelSuperHero]()
                    superHero.forEach{ eachHero in
                        var hero = MarvelSuperHero()
                        hero.name = eachHero.name
                        hero.id = Int(eachHero.id)
                        hero.thumbnail = eachHero.imageUrl
                        hero.descripton = eachHero.desc
                        //hero.index = eachHero.index
                        hero.index = Int(eachHero.key)
                        heros.append(hero)
                    }
                    completion(.success(heros))
                case.failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    private func fetchData(from index: Int, completion: @escaping (Result<[SuperHero],Error>) -> Void ) {
        // 1. Check if data exist in Core Data then return data
        if let superHeros = fetchFromCoreData(from: index) {
            print("values from core data")
            completion(.success(superHeros))
            return
        }
        // 2. Fetch data from MarvelSession, Store in Core Data and return Data
        let client = MarvelClient()
        self.client = client
        client.fetch(offset: index, limit: limit) { [weak self] result in
            switch result {
            case .success(let res):
                //print(res)
                // 3. Store in Core Data and return
                self?.storeToCoreData(model: res, completion: { superHero in
                    if let superHero = superHero, superHero.count > 0 {
                        print("values from client:\(superHero.count)")
                        completion(.success(superHero))
                    } else {
                        return completion(.failure(MarvelDataSourceError.noDataError))
                    }
                })
            case .failure(let error):
                print("MarvelClient error:\(error)")
                completion(.failure(error))
            }
        }
    }
    func clearCache() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: MarvelConstants.superHero.rawValue)
        do {
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            try coreStack.managedContext?.execute(deleteRequest)
        } catch let error {
            print("error: \(error)")
        }
    }
    func update(superHero: SuperHero) {
        guard let managedContext = coreStack.managedContext else {
            return
        }
        let fetchRequest: NSFetchRequest<SuperHero> = SuperHero.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@",  argumentArray: [#keyPath(SuperHero.name), superHero.name])
        fetchRequest.fetchLimit = 1
        var heros = [SuperHero]()
        do {
            heros = try managedContext.fetch(fetchRequest)
        } catch let error {
            print("error fetching hero from coreData: \(error)")
        }
        guard let hero = heros.first else {
            return
        }
        hero.isBookmarked = superHero.isBookmarked
        do {
            try managedContext.save()
            print("values updated: \(superHero)")
        }catch let error {
            print("error saving to coreData: \(error)")
        }
    }
    func comics(id: Int32) -> [String]? {
        guard let managedContext = coreStack.managedContext else {
            return nil
        }
        let fetchRequest: NSFetchRequest<Comic> = Comic.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@",  argumentArray: [#keyPath(Comic.heroID), id])
        var comics = [Comic]()
        do {
            comics = try managedContext.fetch(fetchRequest)
        } catch let error {
            print("error fetching hero from coreData: \(error)")
        }
        let res = comics.compactMap{ $0.name }
        return res
    }
    func series(id: Int32) -> [String]? {
        guard let managedContext = coreStack.managedContext else {
            return nil
        }
        let fetchRequest: NSFetchRequest<Series> = Series.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@",  argumentArray: [#keyPath(Series.heroID), id])
        var arr = [Series]()
        do {
            arr = try managedContext.fetch(fetchRequest)
        } catch let error {
            print("error fetching hero from coreData: \(error)")
        }
        let res = arr.compactMap{ $0.name }
        return res
    }
    func events(id: Int32) -> [String]? {
        guard let managedContext = coreStack.managedContext else {
            return nil
        }
        let fetchRequest: NSFetchRequest<Events> = Events.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@",  argumentArray: [#keyPath(Events.heroID), id])
        var arr = [Events]()
        do {
            arr = try managedContext.fetch(fetchRequest)
        } catch let error {
            print("error fetching hero from coreData: \(error)")
        }
        let res = arr.compactMap{ $0.name }
        return res
    }
    func stories(id: Int32) -> [MarvelStories]? {
        guard let managedContext = coreStack.managedContext else {
            return nil
        }
        let fetchRequest: NSFetchRequest<Stories> = Stories.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@",  argumentArray: [#keyPath(Stories.heroID), id])
        var arr = [Stories]()
        do {
            arr = try managedContext.fetch(fetchRequest)
        } catch let error {
            print("error fetching hero from coreData: \(error)")
        }
        let res = arr.compactMap{ each in
            MarvelStories(name: each.name, type: each.type)
        }
        return res
    }
    func urls(id: Int32) -> [MarvelUrls]? {
        guard let managedContext = coreStack.managedContext else {
            return nil
        }
        let fetchRequest: NSFetchRequest<Resources> = Resources.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@",  argumentArray: [#keyPath(Resources.heroID), id])
        var arr = [Resources]()
        do {
            arr = try managedContext.fetch(fetchRequest)
        } catch let error {
            print("error fetching hero from coreData: \(error)")
        }
        let res = arr.compactMap{ each in
            MarvelUrls(url: each.resourceUrl, type: each.type)
        }
        return res
    }
}

extension MarvelDataSource {
    private func fetchFromCoreData(from index: Int) -> [SuperHero]? {
        guard let managedContext = coreStack.managedContext else {
            return nil
        }
        let fetchRequest: NSFetchRequest<SuperHero> = SuperHero.fetchRequest()
        //fetchRequest.predicate = NSPredicate(format: "%K BEGINSWITH %@",  argumentArray: [#keyPath(SuperHero.name), "H"])
        fetchRequest.predicate = NSPredicate(format: "%K >= %@",  argumentArray: [#keyPath(SuperHero.key), index])
        fetchRequest.fetchLimit = limit
        var heros = [SuperHero]()
        do {
            heros = try managedContext.fetch(fetchRequest)
        } catch let error {
            print("error fetching from coreData: \(error)")
        }
        if heros.count > 0 {
            return heros
        } else {
            return nil
        }
    }
    private func storeToCoreData(model: ClientResponse, completion: @escaping ([SuperHero]?) -> Void ) {
        guard let code = model.code, code == 200 else {
            completion(nil)
            return
        }
        guard let heros = model.data?.results, heros.count > 0 else {
            completion(nil)
            return
        }
        guard let offset = model.data?.offset, offset >= 0 else {
            completion(nil)
            return
        }
        guard let managedContext = coreStack.managedContext else {
            completion(nil)
            return
        }
        var superHeros = [SuperHero]()
        var index: Int32 = Int32(offset)
        for hero in heros {
            guard let name = hero.name, let id = hero.id else {
                continue
            }
            let superHero = SuperHero(context: managedContext)
            superHero.name = name
            superHero.key = index
            superHero.id = Int32(id)
            superHero.desc = hero.desc
            if let image = hero.thumbnail?.path, let ext = hero.thumbnail?.extens {
                superHero.imageUrl = "\(image).\(ext)"
            }
            if let comics = hero.comics?.items, comics.count > 0 {
                for com in comics {
                    if let comicName = com.name, comicName.isEmpty == false {
                        let comic = Comic(context: managedContext)
                        comic.name = comicName
                        comic.heroID = Int32(id)
                    }
                }
            }
            if let allSeries = hero.series?.items, allSeries.count > 0 {
                for series in allSeries {
                    if let seriesName = series.name, seriesName.isEmpty == false {
                        let ser = Series(context: managedContext)
                        ser.name = seriesName
                        ser.heroID = Int32(id)
                    }
                }
            }
            if let allStories = hero.stories?.items, allStories.count > 0 {
                for stories in allStories {
                    if let storiesName = stories.name, storiesName.isEmpty == false {
                        let story = Stories(context: managedContext)
                        story.name = storiesName
                        if let storieType = stories.type, storieType.isEmpty == false {
                            story.type = storieType
                        }
                        story.heroID = Int32(id)
                    }
                }
            }
            if let allEvents = hero.events?.items, allEvents.count > 0 {
                for events in allEvents {
                    if let eventName = events.name, eventName.isEmpty == false {
                        let event = Events(context: managedContext)
                        event.name = eventName
                        event.heroID = Int32(id)
                    }
                }
            }
            if let allUrls = hero.urls , allUrls.count > 0 {
                for urlObj in allUrls {
                    if let type = urlObj.type, let url = urlObj.url {
                        let resource = Resources(context: managedContext)
                        resource.type = type
                        resource.resourceUrl = url
                        resource.heroID = Int32(id)
                    }
                }
            }
            do {
                try managedContext.save()
            } catch let error {
                print("error:\(error)")
            }
            superHeros.append(superHero)
            index += 1
        }
        completion(superHeros)
    }
}
