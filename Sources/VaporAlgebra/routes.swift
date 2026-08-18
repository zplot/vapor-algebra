import Vapor
import AlgebraPackage

func routes(_ app: Application) throws {
    app.get { req async throws in
        try await req.view.render("index", ["title": "Hello Vapor!"])
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }

    app.get("gcd", ":a", ":b") { req async throws -> String in
        guard let a = req.parameters.get("a", as: Int.self),
              let b = req.parameters.get("b", as: Int.self) else {
            throw Abort(.badRequest, reason: "a y b deben ser enteros")
        }
        return "gcd(\(a), \(b)) = \(intGcd(a, b))"
    }

    app.get("factorize", ":n") { req async throws -> String in
        guard let n = req.parameters.get("n", as: Int.self), n >= 1 else {
            throw Abort(.badRequest, reason: "n debe ser un entero positivo")
        }
        let factors = integerFactorization(n)
            .map { "\($0.0)^\($0.1)" }
            .joined(separator: " · ")
        return "\(n) = \(factors)"
    }
}
