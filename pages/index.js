import React from 'react'
import Head from 'next/head'
import Logo from '../components/logo'

export default class extends React.Component {
  static async getInitialProps({ req }) {
    return {
      secretsFromVault: JSON.parse(process.env.app_secrets)
    }
  }

  render() {
    return <div className="root">
      <Head>
        <meta charSet="utf-8"/>
        <meta httpEquiv="X-UA-Compatible" content="IE=edge"/>
        <meta name="viewport" content="width=device-width, initial-scale=1"/>
        <title>Next.js on Heroku</title>
      </Head>
      <style jsx>{`
        .root {
          font-family: sans-serif;
          line-height: 1.33rem;
          margin-top: 8vh,
        }
        @media (min-width: 600px) {
          .root {
            margin-left: 21vw;
            margin-right: 21vw;
          }
        }
        pre {
          font-size: 2rem;
          line-height: 2rem;
        }
      `}</style>

      <h1><Logo style={{ height: '1.45rem' }}/> Secrets from Vault</h1>

      <pre>{JSON.stringify(this.props.secretsFromVault, null, 2)}</pre>
    </div>
  }
}