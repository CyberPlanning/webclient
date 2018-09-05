module FakeQuery exposing (createFakeQuery)

import Json.Decode as Json
import Types exposing (Event, Planning, Query, decodeQuery)
import Debug

createFakeQuery : Query
createFakeQuery =
    let
        res =
            Json.decodeString decodeQuery """
{
    "planning": {
        "events": [
            {
                "title": "Titre1",
                "startDate": "2017-01-02T12:00:00",
                "endDate": "2017-01-02T14:00:00",
                "groups": [
                    "G1",
                    "G2"
                ],
                "classrooms": [
                    "CR1",
                    "CR2"
                ],
                "teachers": [
                    "M.Duhdeu",
                    "Mme.Feef"
                ]
            },
            {
                "title": "Titre2",
                "startDate": "2017-01-02T14:00:00",
                "endDate": "2017-01-02T16:00:00",
                "groups": [
                    "G1",
                    "G2"
                ],
                "classrooms": [
                    "CR1",
                    "CR2"
                ],
                "teachers": [
                    "M.Duhdeu",
                    "Mme.Feef"
                ]
            },
            {
                "title": "Titre3",
                "startDate": "2017-01-02T16:00:00",
                "endDate": "2017-01-02T18:00:00",
                "groups": [
                    "G1",
                    "G2"
                ],
                "classrooms": [
                    "CR1",
                    "CR2"
                ],
                "teachers": [
                    "M.Duhdeu",
                    "Mme.Feef"
                ]
            }
        ]
    }
}"""
    in
    case res of
        Ok query ->
            query

        Err error ->
            Query (Planning [ Event (Debug.toString error) "" "" [] [] [] ])
